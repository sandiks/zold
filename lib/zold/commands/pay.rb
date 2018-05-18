# Copyright (c) 2018 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'slop'
require_relative '../log'

# PAY command.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018 Yegor Bugayenko
# License:: MIT
module Zold
  # Money sending command
  class Pay
    def initialize(wallets:, log: Log::Quiet.new)
      @wallets = wallets
      @log = log
    end

    def run(args = [])
      opts = Slop.parse(args, help: true, suppress_errors: true) do |o|
        o.banner = "Usage: zold pay wallet target amount [details] [options]
Where:
    'wallet' is the sender's wallet ID
    'target' is the beneficiary (either wallet ID or invoice number)'
    'amount' is the amount to pay, in ZLD, for example '14.95'
    'details' is the optional text to attach to the payment
Available options:"
        o.string '--private-key',
          'The location of RSA private key (default: ~/.ssh/id_rsa)',
          require: true,
          default: '~/.ssh/id_rsa'
        o.bool '--force',
          'Ignore all validations',
          default: false
        o.bool '--help', 'Print instructions'
      end
      if opts.help?
        @log.info(opts.to_s)
        return
      end
      mine = opts.arguments[1..-1]
      raise 'Payer wallet ID is required as the first argument' if mine[0].nil?
      from = @wallets.find(Zold::Id.new(mine[0]))
      raise 'Wallet doesn\'t exist, do \'fetch\' first' unless from.exists?
      raise 'Recepient\'s invoice or wallet ID is required as the second argument' if mine[1].nil?
      target = mine[1]
      if target.include?('@')
        invoice = target
      else
        require_relative 'invoice'
        invoice = Invoice.new(wallets: @wallets, log: @log).run(['invoice', target])
      end
      raise 'Amount is required (in ZLD) as the third argument' if mine[2].nil?
      amount = Zold::Amount.new(zld: mine[2].to_f)
      details = mine[3] ? mine[3] : '-'
      pay(from, invoice, amount, details, opts)
    end

    def pay(from, invoice, amount, details, opts)
      unless opts.force?
        raise 'The amount can\'t be zero' if amount.zero?
        raise "The amount can't be negative: #{amount}" if amount.negative?
        if !from.root? && from.balance < @amount
          raise "There is not enough funds in #{from} to send #{amount}, only #{payer.balance} left"
        end
      end
      key = Zold::Key.new(file: opts['private-key'])
      txn = from.sub(amount, invoice, key, details)
      @log.debug("#{amount} sent from #{from} to #{txn.bnf}: #{details}")
      @log.info(txn.id)
      txn
    end
  end
end

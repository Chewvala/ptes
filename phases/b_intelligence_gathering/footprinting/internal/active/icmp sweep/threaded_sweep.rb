#!/usr/bin/env ruby
require 'net/ping'; require 'rainbow/ext/string'

# This multi-threaded script will run an ICMP sweep on a network range, output if the host is up/down, & report packet metrics.

 def banner()
 print """
'####::'######::'##::::'##:'########::::::'######::'##:::::'##:'########:'########:'########::'########:'########::
. ##::'##... ##: ###::'###: ##.... ##::::'##... ##: ##:'##: ##: ##.....:: ##.....:: ##.... ##: ##.....:: ##.... ##:
: ##:: ##:::..:: ####'####: ##:::: ##:::: ##:::..:: ##: ##: ##: ##::::::: ##::::::: ##:::: ##: ##::::::: ##:::: ##:
: ##:: ##::::::: ## ### ##: ########:::::. ######:: ##: ##: ##: ######::: ######::: ########:: ######::: ########::
: ##:: ##::::::: ##. #: ##: ##.....:::::::..... ##: ##: ##: ##: ##...:::: ##...:::: ##.....::: ##...:::: ##.. ##:::
: ##:: ##::: ##: ##:.:: ##: ##:::::::::::'##::: ##: ##: ##: ##: ##::::::: ##::::::: ##:::::::: ##::::::: ##::. ##::
'####:. ######:: ##:::: ##: ##:::::::::::. ######::. ###. ###:: ########: ########: ##:::::::: ########: ##:::. ##:
....:::......:::..:::::..::..:::::::::::::......::::...::...:::........::........::..:::::::::........::..:::::..::                                                            
                           [Multi-threaded ICMP Sweeper v0.0.1, Rick Flores (@nanotechz9l)]                                             

""".foreground(:cyan).bright
end
banner()

network   = ARGV[0]
list      = []
host_up   = []
host_down = []
pingfails = 0
repeat    = 1
x         = 0

unless ARGV.length == 1
puts "\n\nMissing argument!\n\n".foreground(:red).bright.blink
puts "Example. #{$0} 74.125.224 or #{$0} google.com".foreground(:green).bright
puts "\nThis script will run an ICMP sweep on a network range, output if the host is up/down, & report packet metrics.".foreground(:yellow).bright
puts "To start enter the first three IP octets only. The fourth octet range from .0-255 is already hardcoded into the program.".foreground(:yellow).bright
puts "DONT".foreground(:red).underline + " enter a period after the 3rd octet or you'll get invalid results. Enter exactly like this: 74.125.224\n".foreground(:yellow).bright
prompt    = 'ping sweep IP range:~$ '.foreground(:cyan).bright 
end

#print prompt
#network = STDIN.gets.chomp()
network = ARGV[0]

puts "starting sweep on ".foreground(:cyan).bright + "#{network}.0-255\n".foreground(:yellow).bright
while x < 255
  ip = network + '.' + x.to_s
  list.push(ip)
  x += 1
end

# Multi-threaded config
  Thread.abort_on_exception = true
  threads = list.map { |x|
    t = Thread.new {
    pt = Net::Ping::External.new(x)
    if pt.ping
      host_up << pt.duration
      puts "#{x} ".ljust(20).foreground(:yellow).bright + "<- replied in #{pt.duration} seconds".foreground(:green).bright
    else
      host_down.push(x)
      pingfails += 1
      puts "#{x} ".ljust(20).foreground(:yellow).bright + "[X] no response (timeout). Host might be up. Try nmap <IP> -Pn!".foreground(:red).bright
    end
  }
}

	# Wait for all threads to finish via join method
threads.each {|th| th.join}

# Report average round-trip packet responses
avg = host_up.inject(0) {|sum, i| sum + i}/(repeat - pingfails)
puts "\nAverage round-trip is #{avg} seconds".foreground(:yellow).bright
puts "#{pingfails}".foreground(:red).bright + " packet/s dropped!".foreground(:yellow).bright

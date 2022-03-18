#run script to open the port
#check server name with ttl - nslookup -debug ops01.net
#modify host file on server 1 and 2
#check connection - telnet ops01.net 8001
#see all ports netstat -a
$port=8001
$endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port)
$listener = new-object System.Net.Sockets.TcpListener $endpoint

while ($true){
$listener.start()
$client = $listener.AcceptTcpClient()
"Client connected:"
$client
pause
}

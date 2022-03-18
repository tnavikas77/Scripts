#run script to open the port and check connection between servers
#check server name in dns nslookup servername
#modify host file on server 1 and 2
#telnet dns 8001 to connect
#netstat -a to see connection
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
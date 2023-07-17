# ssl_monitoring
For example, running the command:
./check_ssl_certificate.sh -u www.example.com:443
Will display:
OK: SSL certificate for www.example.com:443 is still valid for 92 days until
It can also check file, when using switch -f
When cert is due less than 2 weeks, it will display WARNING message as well as exit with code 1 so it is already capable of triggering any monitoring tool

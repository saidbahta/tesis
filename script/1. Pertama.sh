SNORT_LOG_DIR="/var/log/snort/"
BOMA_LOG_DIR="/var/log/snort/boma"

if [ ! -d "$BOMA_LOG_DIR" ]; then mkdir -p "$BOMA_LOG_DIR"; else echo "Folder telah tersedia"; fi

inotifywait -q -m -e modify "$SNORT_LOG_DIR/alert" | 
while read events; 
do cat "$SNORT_LOG_DIR/alert" | awk '{print($4,$5,$6,$3,$11,$12,$13)}' | uniq -c > "$BOMA_LOG_DIR/alertF";

cat "$BOMA_LOG_DIR/alertF" | awk '{print "iptables -I INPUT -s "$6" -j DROP"}' > "$BOMA_LOG_DIR/ips-rule.sh"

chmod +x "$BOMA_LOG_DIR/ips-rule.sh"
"$BOMA_LOG_DIR/ips-rule.sh"

done





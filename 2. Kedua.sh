SNORT_LOG_DIR="/var/log/snort/"
BOMA_LOG_DIR="/var/log/snort/boma"
BOMA_RULES="/var/log/snort/boma/ips-rule.sh"

# Make direktory boma
if [ ! -d "$BOMA_LOG_DIR" ]; then 
	mkdir -p "$BOMA_LOG_DIR"; 
fi
# Create ips-rule.sh 
if [ ! -f "$BOMA_RULES" ]; then 
	touch "$BOMA_RULES"; 
fi

# Wait for change in alert file, then create alertF (alert_filter) file  
inotifywait -q -m -e modify "$SNORT_LOG_DIR/alert" | 
while read events; 
do cat "$SNORT_LOG_DIR/alert" | awk '{print($4,$5,$6,$3,$11,$12,$13)}' | uniq -c > "$BOMA_LOG_DIR/alertF";

ALERT_FILTER=$(wc -l $BOMA_LOG_DIR/alertF | awk '{print $1}')
IPS_RULE=$(wc -l $BOMA_LOG_DIR/ips-rule.sh | awk '{print $1}')
# Compare alertF and ips-rule.sh so that the ips-rules.sh only run when there is a new kind of rule
if [ "$ALERT_FILTER" == "$IPS_RULE" ]; then  
	continue 
else  
cat "$BOMA_LOG_DIR/alertF" | awk '{print "iptables -I INPUT -s "$6" -j DROP"}' > "$BOMA_LOG_DIR/ips-rule.sh"
chmod +x "$BOMA_LOG_DIR/ips-rule.sh"
"$BOMA_LOG_DIR/ips-rule.sh"
fi
done


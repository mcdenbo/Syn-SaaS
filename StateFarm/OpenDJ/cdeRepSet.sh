

#
# Build the first replication agreement for the schema branch
#
/opt/opendj/bin/dsreplication enable --host1 ${MASTER} \
 --port1 ${ADMINPORT} \
 --bindDN1 "cn=Directory Manager" \
 --bindPassword1 ${OPENDJ_PWD} \
 --replicationPort1 ${REP_PORT} \
 --host2 ${FQDN} \
 --port2 ${ADMINPORT} \
 --bindDN2 "cn=Directory Manager" \
 --bindPassword2 ${OPENDJ_PWD} \
 --replicationPort2 ${REP_PORT} \
 --adminUID admin \
 --adminPassword ${OPENDJ_PWD} \
 --baseDN "cn=schema" -X -n 1>>$INSTALL_LOG 2>>$INSTALL_LOG

echo "Finished ${MASTER} cn=schema Replication Configuration" >> $INSTALL_LOG
echo "" >> $INSTALL_LOG
sleep 1

#
# Build the Second replication agreement for the Directory Server
#
/opt/opendj/bin/dsreplication enable --host1 ${MASTER} \
 --port1 ${ADMINPORT} \
 --bindDN1 "cn=Directory Manager" \
 --bindPassword1 ${OPENDJ_PWD} \
 --replicationPort1 ${REP_PORT} \
 --host2 ${FQDN} \
 --port2 ${ADMINPORT} \
 --bindDN2 "cn=Directory Manager" \
 --bindPassword2 ${OPENDJ_PWD} \
 --replicationPort2 ${REP_PORT} \
 --adminUID admin \
 --adminPassword ${OPENDJ_PWD} \
 --baseDN "dc=statefarm,dc=com" -X -n 1>>$INSTALL_LOG 2>>$INSTALL_LOG

echo "Finished ${MASTER} dc=statefarm,dc=com Replication Configuration" >> $INSTALL_LOG
echo "" >> $INSTALL_LOG
sleep 1

#
# Replication Initialization for the State Farm Branch of the Directory
#
#
# Requires the Primary and Destination servers FQDN,
# the administration port, the ports to be used for replication,
# and the Password for Dirctory Manager and admin
#

/opt/opendj/bin/dsreplication initialize --baseDN "dc=statefarm,dc=com" \
 --adminUID admin \
 --adminPassword ${OPENDJ_PWD} \
 --hostSource ${MASTER} \
 --portSource ${ADMINPORT} \
 --hostDestination ${FQDN} \
 --portDestination ${ADMINPORT} -X -n

echo "Finished ${FQDN} dc=statefarm,dc=com Replication Initialization" >> $INSTALL_LOG
echo "" >> $INSTALL_LOG

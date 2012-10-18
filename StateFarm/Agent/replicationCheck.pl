#!/bin/perl -w

# This script verifies that replication of a specific test entry works to each host
# specified, from each master specified.

# Bind credentials
$BINDDN = '"cn=directory manager"';
$BINDPW = 'CDEopendj';

# All hosts to be checked
@hosts = ('vms015','vms035','vms036','vms037','vms038');

# Masters to be updated
@masters = ('vms015');

# Suffixes to be updated
@suffixes = ('o=residential,dc=vol,dc=verizon,dc=net','o=pab','o=comms-config');

# unique cn of the test entry - if it already exists on any host on any suffix the script will die
$usercn = 'chris-test';

# How log to wait for the changes to be replicated
$delay = '1';
# Make sure the test entry is not present on any host
foreach $host (@hosts) {
 foreach $suffix (@suffixes) {
   $result = `ldapsearch -L -h $host -D $BINDDN -w $BINDPW -b \"$suffix\" \"cn=$usercn\" dn \| grep \"^dn: \" \| wc -l`;
   $result =~ (/(\d+)/);
   if ($1 ne '0') {
     die "ERROR $host already has test user $usercn\!\n";
   }
 }
}

# Add test entries to each master
foreach $master (@masters) {
 open(MOD,"|ldapmodify -h $master -D $BINDDN -w $BINDPW");
 foreach $suffix (@suffixes) {
   print MOD "dn: cn=$usercn,$suffix\nchangetype: add\nobjectclass: top\nobjectclass: person\ncn: $usercn\nsn: $usercn\n\n";
 }
 close(MOD);

# Sleep to allow replication
 sleep($delay);

# Search each host, each suffix and report
 foreach $host (@hosts) {
   foreach $suffix (@suffixes) {
     $result = `ldapsearch -L -h $host -D $BINDDN -w $BINDPW -b \"$suffix\" \"cn=$usercn\" dn \| grep \"^dn: \" \| wc -l`;
     $result =~ (/(\d+)/);
     if ($1 ne '1') {
       print "FAILED: $master -> $host on suffix $suffix\n";
     }
     else {
        print "OK: $master -> $host on suffix $suffix\n";
     }
   }
   print "\n";
 }

# Clean up test entries
 open(MOD,"|ldapmodify -h $master -D $BINDDN -w $BINDPW");
 foreach $suffix (@suffixes) {
   print MOD "dn: cn=$usercn,$suffix\nchangetype: delete\n\n";
 }
 close(MOD);
 print "\n";
}

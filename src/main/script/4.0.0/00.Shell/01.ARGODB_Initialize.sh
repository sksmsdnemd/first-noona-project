
echo "# ========================================================================="
echo "# ARGO DB Initialize... "
echo "# START Time : " `date` 
echo "# ========================================================================="

#!/bin/bash
#sqlplus connect
sqlplus -SILENT "/as sysdba" <<EOF
set heading off
set echo off
set term on
set feedback on
spool ../Log/01.ARGODB_Initialize.Log

#Run Query
@../01.User/ARGODB_Create_User.SQL <<EOF

spool off
EOF

echo "# ========================================================================="
echo "# Initialize Finish Time : " `date` 
echo "# ========================================================================="


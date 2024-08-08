
echo "# ========================================================================="
echo "# ARGO DB Create Tablespace Start... "
echo "# START Time : " `date` 
echo "# ========================================================================="

#!/bin/bash
#sqlplus connect
sqlplus  -SILENT ARGO/argo@ARGODB <<EOF
set heading off
set echo off
set term on
set feedback on
spool ../Log/02.ARGODB_Create_TableSpace.Log

#Run Query
@../02.TableSpace/ARGODB_Create_Tablespace.SQL <<EOF

spool off
EOF

echo "# ========================================================================="
echo "# Create Tablespace Finish Time : " `date` 
echo "# ========================================================================="


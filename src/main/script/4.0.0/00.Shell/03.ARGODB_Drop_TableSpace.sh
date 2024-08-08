
echo "# ========================================================================="
echo "# ARGO DB Drop Tablespace Start... "
echo "# START Time : " `date` 
echo "# ========================================================================="

#!/bin/bash
#sqlplus connect
sqlplus  -SILENT ARGO/argo@ARGODB <<EOF
set heading off
set echo off
set term on
set feedback on
spool ../Log/03.ARGODB_Drop_TableSpace.Log

#Run Query
@../02.TableSpace/ARGODB_Drop_Tablespace.SQL <<EOF

spool off
EOF

echo "# ========================================================================="
echo "# Drop Tablespace Finish Time : " `date` 
echo "# ========================================================================="



echo "# ========================================================================="
echo "# ARGO DB Create ArgoCM tables Start... "
echo "# START Time : " `date` 
echo "# ========================================================================="

#!/bin/bash
#sqlplus connect
sqlplus  -SILENT ARGO/argo@ARGODB <<EOF
set heading off
set echo off
set term on
set feedback on
spool ../Log/04.ARGODB_Table_ArgoCM.Log

#Run Query
@../03.Table/ARGOCM_Create_Table.SQL <<EOF

spool off
EOF

echo "# ========================================================================="
echo "# Create ArgoCM tables Finish Time : " `date` 
echo "# ========================================================================="


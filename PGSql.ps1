$MyServer = "localhost"
$MyPort  = "5432"
$MyDB = "Noah"
$MyUid = "postgres"
$MyPass = "postgres"

$DBConnectionString = "Driver={PostgreSQL ANSI};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();
$DBCmd = $DBConn.CreateCommand();
$DBCmd.CommandText = "SELECT * FROM population;";
$DBCmd.ExecuteReader();
$DBConn.Close();
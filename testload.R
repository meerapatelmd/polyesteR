cd <- DatabaseConnector::createConnectionDetails(
        dbms     = "postgresql", 
        server   = "localhost/synthea10", 
        user     = "meerapatel", 
        password = "", 
        port     = 5432,
        schema = "cdm_synthea10"
)


conn <- DatabaseConnector::connect(cd)

cdmDatabaseSchema <- "cdm_synthea10"
queries <- c("create_source_to_standard_vocab_map.sql", "create_source_to_source_vocab_map.sql")
query <- queries[1]
pathToSql <- base::system.file("sql/sql_server", package = "ETLSyntheaBuilder")
sqlFile <- base::paste0(pathToSql, "/", query)
sqlQuery <- base::readChar(sqlFile, base::file.info(sqlFile)$size)
renderedSql <- SqlRender::render(sqlQuery, cdm_schema = cdmDatabaseSchema)
translatedSql <- SqlRender::translate(renderedSql, targetDialect = cd$dbms)
writeLines(paste0("Running: ", query))
DatabaseConnector::executeSql(conn, translatedSql, progressBar = TRUE, 
                              reportOverallTime = TRUE)
}
on.exit(DatabaseConnector::disconnect(conn))


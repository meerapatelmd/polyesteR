
connect_to_polyester <-
        function(schema_name)  {
                require(DatabaseConnector)
                conn_desc <<-
                        DatabaseConnector::createConnectionDetails(
                                dbms = "postgresql",
                                user = "meerapatel",
                                password = "",
                                server = "localhost/polyester",
                                schema = schema_name
                        )
                
                conn <<-
                        DatabaseConnector::connect(conn_desc)
        }

execute_synthea_ddl <-
        function() {
                sqlFile <- "synthea_ddl.sql"
                sqlQuery <- base::readChar(sqlFile, base::file.info(sqlFile)$size)
                renderedSql <- SqlRender::render(sqlQuery)
                translatedSql <- SqlRender::translate(renderedSql, targetDialect = conn_desc$dbms)
                DatabaseConnector::executeSql(conn, translatedSql, progressBar = TRUE, 
                                              reportOverallTime = TRUE) 
        }

execute_omop_vocab_v5_ddl <-
        function() {
                sqlFile <- "omop_vocab_v5_ddl.sql"
                sqlQuery <- base::readChar(sqlFile, base::file.info(sqlFile)$size)
                renderedSql <- SqlRender::render(sqlQuery)
                translatedSql <- SqlRender::translate(renderedSql, targetDialect = conn_desc$dbms)
                DatabaseConnector::executeSql(conn, translatedSql, progressBar = TRUE, 
                                              reportOverallTime = TRUE) 
        }

insert_data_into_synthea_tables <-
        function(dataframe, table_name_col, data_robj_name_col) {
                table_name_col <- enquo(table_name_col)
                data_robj_name_col <- enquo(data_robj_name_col)
                
                tablenames <- dataframe %>% select(!!table_name_col)  %>% unname() %>% unlist()
                robjnames <- dataframe %>% select(!!data_robj_name_col) %>% unname() %>% unlist()
                
                print(tablenames)
                print(robjnames)
                stop_and_enter()
                
                
                for (i in 1:length(tablenames)) {
                        DatabaseConnector::dbAppendTable(conn, 
                                                         tablenames[i],
                                                         robjnames[i]
                        )
                }                                         
        }

for (i in 1:100) {
        if (length(list.files("./CONTROL/NEW"))) {
                x <- read.csv(list.files("./CONTROL/NEW", full.names = TRUE)[1])
                tablename <- tolower(remove_file_ext_from_fn(list.files("./CONTROL/NEW", full.names = FALSE)[1]))
                dbAppendTable(conn, tablename, value = x)
                file.rename(list.files("./CONTROL/NEW", full.names = TRUE)[1],
                            paste0("./CONTROL/LOADED/", list.files("./CONTROL/NEW", full.names = FALSE)[1]))
        }
}

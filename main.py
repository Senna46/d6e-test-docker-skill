#!/usr/bin/env python3
"""
D6E Docker STF Test Image

This is a test implementation for validating D6E Docker runtime functionality.
Tests: input parsing, SQL execution, output generation, error handling.
"""

import sys
import json
import requests
import logging

# Configure logging to stderr
logging.basicConfig(
    stream=sys.stderr,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def execute_sql(api_url, api_token, workspace_id, stf_id, sql):
    """Execute SQL via D6E internal API"""
    url = f"{api_url}/api/v1/workspaces/{workspace_id}/sql"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "X-Internal-Bypass": "true",
        "X-Workspace-ID": workspace_id,
        "X-STF-ID": stf_id,
        "Content-Type": "application/json"
    }
    
    logging.info(f"Executing SQL: {sql[:100]}...")
    response = requests.post(url, json={"sql": sql}, headers=headers)
    
    if not response.ok:
        error_msg = f"SQL execution failed: {response.status_code} {response.text}"
        logging.error(error_msg)
        raise Exception(error_msg)
    
    result = response.json()
    logging.info(f"SQL execution successful: {len(result.get('rows', []))} rows")
    return result

def main():
    try:
        # Read input from stdin
        logging.info("Reading input from stdin...")
        input_data = json.load(sys.stdin)
        
        workspace_id = input_data["workspace_id"]
        stf_id = input_data["stf_id"]
        user_input = input_data["input"]
        sources = input_data["sources"]
        caller = input_data["caller"]
        api_url = input_data["api_url"]
        api_token = input_data["api_token"]
        
        logging.info(f"Workspace: {workspace_id}")
        logging.info(f"STF: {stf_id}")
        logging.info(f"Caller: {caller}")
        logging.info(f"Input: {json.dumps(user_input)}")
        logging.info(f"Sources: {list(sources.keys())}")
        
        # Test operation based on input
        operation = user_input.get("operation", "test")
        
        if operation == "test":
            # Simple test: return input and sources
            output = {
                "output": {
                    "status": "success",
                    "message": "Docker STF test execution successful",
                    "received_input": user_input,
                    "received_sources": list(sources.keys()),
                    "caller": caller
                }
            }
        
        elif operation == "sql_select":
            # Test SQL SELECT
            table_name = user_input.get("table_name", "test_table")
            result = execute_sql(
                api_url, api_token, workspace_id, stf_id,
                f"SELECT * FROM {table_name} LIMIT 10"
            )
            output = {
                "output": {
                    "status": "success",
                    "operation": "sql_select",
                    "table": table_name,
                    "rows": result.get("rows", []),
                    "count": len(result.get("rows", []))
                }
            }
        
        elif operation == "sql_insert":
            # Test SQL INSERT
            table_name = user_input.get("table_name", "test_table")
            data = user_input.get("data", {})
            
            # Build INSERT query
            columns = list(data.keys())
            values = [data[col] for col in columns]
            # Escape single quotes in values
            escaped_values = [str(v).replace("'", "''") for v in values]
            placeholders = [f"'{val}'" for val in escaped_values]
            
            columns_str = ', '.join(columns)
            values_str = ', '.join(placeholders)
            insert_sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({values_str}) RETURNING *"
            result = execute_sql(
                api_url, api_token, workspace_id, stf_id,
                insert_sql
            )
            
            output = {
                "output": {
                    "status": "success",
                    "operation": "sql_insert",
                    "table": table_name,
                    "inserted": result.get("rows", [])
                }
            }
        
        elif operation == "sql_update":
            # Test SQL UPDATE
            table_name = user_input.get("table_name", "test_table")
            set_data = user_input.get("set", {})
            where = user_input.get("where", "")
            
            # Build SET clause with escaped values
            set_parts = []
            for k, v in set_data.items():
                escaped_val = str(v).replace("'", "''")
                set_parts.append(f"{k} = '{escaped_val}'")
            set_clause = ", ".join(set_parts)
            
            update_sql = f"UPDATE {table_name} SET {set_clause}"
            if where:
                update_sql += f" WHERE {where}"
            
            result = execute_sql(
                api_url, api_token, workspace_id, stf_id,
                update_sql
            )
            
            output = {
                "output": {
                    "status": "success",
                    "operation": "sql_update",
                    "table": table_name,
                    "affected_rows": result.get("affected_rows", 0)
                }
            }
        
        elif operation == "error":
            # Test error handling
            raise Exception("Intentional error for testing")
        
        else:
            output = {
                "output": {
                    "status": "error",
                    "message": f"Unknown operation: {operation}"
                }
            }
        
        # Output result to stdout
        print(json.dumps(output))
        logging.info("Execution completed successfully")
        
    except Exception as e:
        logging.error(f"Error during execution: {str(e)}", exc_info=True)
        # Output error in proper format
        error_output = {
            "output": {
                "status": "error",
                "error": str(e)
            }
        }
        print(json.dumps(error_output))
        sys.exit(1)

if __name__ == "__main__":
    main()

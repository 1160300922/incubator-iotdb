/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
namespace java org.apache.iotdb.service.rpc.thrift


// The return status code contained in each response.
enum TS_StatusCode {
  SUCCESS_STATUS,
  SUCCESS_WITH_INFO_STATUS,
  STILL_EXECUTING_STATUS,
  ERROR_STATUS,
  INVALID_HANDLE_STATUS
}

// The return status of a remote request
struct TS_Status {
  1: required TS_StatusCode statusCode

  // If status is SUCCESS_WITH_INFO, info_msgs may be populated with
  // additional diagnostic information.
  2: optional list<string> infoMessages

  // If status is ERROR, then the following fields may be set
  3: optional string sqlState  // as defined in the ISO/IEF CLI specification
  4: optional i32 errorCode    // internal error code
  5: optional string errorMessage
}

struct TSHandleIdentifier {
  // 16 byte globally unique identifier This is the public ID of the handle and can be used for reporting.
  // In current version, it is not used.
  1: required binary guid,

  // 16 byte secret generated by the server and used to verify that the handle is not being hijacked by another user.
  // In current version, it is not used.
  2: required binary secret,
}

// Client-side reference to a QPTask running asynchronously on the server.
struct TSOperationHandle {
  1: required TSHandleIdentifier operationId

  // If hasResultSet = TRUE, then this operation
  // generates a result set that can be fetched.
  // Note that the result set may be empty.
  //
  // If hasResultSet = FALSE, then this operation
  // does not generate a result set, and calling
  // GetResultSetMetadata or FetchResults against
  // this OperationHandle will generate an error.
  2: required bool hasResultSet
}

struct TSExecuteStatementResp {
	1: required TS_Status status
	2: optional TSOperationHandle operationHandle
  // Column names in select statement of SQL
	3: optional list<string> columns
	4: optional string operationType
	5: optional bool ignoreTimeStamp
}

enum TSProtocolVersion {
  TSFILE_SERVICE_PROTOCOL_V1,
}

// Client-side handle to persistent session information on the server-side.
// In current version, it is not used.
struct TS_SessionHandle {
  1: required TSHandleIdentifier sessionId
}


struct TSOpenSessionResp {
  1: required TS_Status status

  // The protocol version that the server is using.
  2: required TSProtocolVersion serverProtocolVersion = TSProtocolVersion.TSFILE_SERVICE_PROTOCOL_V1

  // Session Handle
  3: optional TS_SessionHandle sessionHandle

  // The configuration settings for this session.
  4: optional map<string, string> configuration
}

// OpenSession()
// Open a session (connection) on the server against which operations may be executed.
struct TSOpenSessionReq {
  1: required TSProtocolVersion client_protocol = TSProtocolVersion.TSFILE_SERVICE_PROTOCOL_V1
  2: optional string username
  3: optional string password
  4: optional map<string, string> configuration
}

struct TSCloseSessionResp {
  1: required TS_Status status
}

// CloseSession()
// Closes the specified session and frees any resources currently allocated to that session. 
// Any open operations in that session will be canceled.
struct TSCloseSessionReq {
  1: required TS_SessionHandle sessionHandle
}

// ExecuteStatement()
//
// Execute a statement.
// The returned OperationHandle can be used to check on the status of the statement, and to fetch results once the
// statement has finished executing.
struct TSExecuteStatementReq {
  // The session to execute the statement against
  1: required TS_SessionHandle sessionHandle

  // The statement to be executed (DML, DDL, SET, etc)
  2: required string statement
}


struct TSExecuteBatchStatementResp{
	1: required TS_Status status
  // For each value in result, Statement.SUCCESS_NO_INFO represents success, Statement.EXECUTE_FAILED represents fail otherwise.
	2: optional list<i32> result
}

struct TSExecuteBatchStatementReq{
  // The session to execute the statement against
  1: required TS_SessionHandle sessionHandle

  // The statements to be executed (DML, DDL, SET, etc)
  2: required list<string> statements
}


struct TSGetOperationStatusReq {
  // Session to run this request against
  1: required TSOperationHandle operationHandle
}

struct TSGetOperationStatusResp {
  1: required TS_Status status
}

// CancelOperation()
//
// Cancels processing on the specified operation handle and frees any resources which were allocated.
struct TSCancelOperationReq {
  // Operation to cancel
  1: required TSOperationHandle operationHandle
}

struct TSCancelOperationResp {
  1: required TS_Status status
}


// CloseOperation()
struct TSCloseOperationReq {
  1: required TSOperationHandle operationHandle
  2: required i64 queryId
}

struct TSCloseOperationResp {
  1: required TS_Status status
}

struct TSDataValue{
  1: required bool is_empty
  2: optional bool bool_val
  3: optional i32 int_val
  4: optional i64 long_val
  5: optional double float_val
  6: optional double double_val
  7: optional binary binary_val
  8: optional string type;
}

struct TSRowRecord{
  1: required i64 timestamp
  // column values
  2: required list<TSDataValue> values
}

struct TSQueryDataSet{
	1: required list<TSRowRecord> records
}

struct TSFetchResultsReq{
	1: required string statement
	2: required i32 fetch_size
	3: required i64 queryId
}

struct TSFetchResultsResp{
	1: required TS_Status status
	2: required bool hasResultSet
	3: optional TSQueryDataSet queryDataSet
}

struct TSFetchMetadataResp{
		1: required TS_Status status
		2: optional string metadataInJson
		3: optional list<string> ColumnsList
		4: optional string dataType
		5: optional list<list<string>> showTimeseriesList
		7: optional set<string> showStorageGroups
}

struct TSFetchMetadataReq{
		1: required string type
		2: optional string columnPath
}

struct TSColumnSchema{
	1: optional string name;
	2: optional string dataType;
	3: optional string encoding;
	4: optional map<string, string> otherArgs;
}

struct TSGetTimeZoneResp {
    1: required TS_Status status
    2: required string timeZone
}

struct TSSetTimeZoneReq {
    1: required string timeZone
}

struct TSSetTimeZoneResp {
    1: required TS_Status status
}

struct ServerProperties {
	1: required string version;
	2: required list<string> supportedTimeAggregationOperations;
}

service TSIService {
	TSOpenSessionResp openSession(1:TSOpenSessionReq req);

	TSCloseSessionResp closeSession(1:TSCloseSessionReq req);

	TSExecuteStatementResp executeStatement(1:TSExecuteStatementReq req);

	TSExecuteBatchStatementResp executeBatchStatement(1:TSExecuteBatchStatementReq req);

	TSExecuteStatementResp executeQueryStatement(1:TSExecuteStatementReq req);

	TSExecuteStatementResp executeUpdateStatement(1:TSExecuteStatementReq req);

	TSFetchResultsResp fetchResults(1:TSFetchResultsReq req)

	TSFetchMetadataResp fetchMetadata(1:TSFetchMetadataReq req)

	TSCancelOperationResp cancelOperation(1:TSCancelOperationReq req);

	TSCloseOperationResp closeOperation(1:TSCloseOperationReq req);

	TSGetTimeZoneResp getTimeZone();

	TSSetTimeZoneResp setTimeZone(1:TSSetTimeZoneReq req);
	
	ServerProperties getProperties();
	}

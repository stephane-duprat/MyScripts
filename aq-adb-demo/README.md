# Advanced Queuing on Autonomous AI Database

This demo creates an Oracle Advanced Queuing queue in Autonomous AI Database and runs a small Java consumer that dequeues JSON messages from it.

The queue uses a `RAW` payload so the Java side can stay small: messages are UTF-8 JSON bytes, dequeued through the Oracle JDBC AQ API.

## What You Need

- An Autonomous AI Database or Autonomous Database instance
- A database user that can create AQ queues, or access to `ADMIN` to create the demo user
- The database wallet unzipped locally
- JDK 17+
- Maven 3.9+
- SQLcl, SQL Developer, or another Oracle SQL client

## 1. Create a Demo Schema

If you already have a schema with AQ privileges, skip this step.

Edit `sql/00_create_user_as_admin.sql` and change the password, then run it as `ADMIN`:

```bash
sql 'ADMIN/<admin-password>@yourdb_tp?TNS_ADMIN=/full/path/to/Wallet_yourdb' @sql/00_create_user_as_admin.sql
```

## 2. Create the Queue

Connect as the demo user and create the AQ queue:

```bash
sql 'aqdemo/<password>@yourdb_tp?TNS_ADMIN=/full/path/to/Wallet_yourdb' @sql/01_create_queue.sql
```

The script creates:

- Queue table: `ORDER_EVENTS_QTAB`
- Queue: `ORDER_EVENTS_Q`
- Payload type: `RAW`

## 3. Build the Java Consumer

```bash
mvn package
```

## 4. Run the Consumer

Use a wallet-backed JDBC URL. For example:

```bash
export DB_URL='jdbc:oracle:thin:@yourdb_tp?TNS_ADMIN=/full/path/to/Wallet_yourdb'
export DB_USER='aqdemo'
export DB_PASSWORD='<password>'
export AQ_QUEUE='ORDER_EVENTS_Q'
export AQ_MAX_MESSAGES=0
export AQ_WAIT_SECONDS=30

java -jar target/aq-adb-consumer-1.0.0.jar
```

`AQ_MAX_MESSAGES=0` means the consumer keeps listening. Set it to a number, such as `5`, when you want the process to stop after a fixed count.

## 5. Enqueue Test Messages

In a second terminal, enqueue one message:

```bash
sql 'aqdemo/<password>@yourdb_tp?TNS_ADMIN=/full/path/to/Wallet_yourdb' @sql/02_enqueue_sample.sql
```

Or enqueue a small batch:

```bash
sql 'aqdemo/<password>@yourdb_tp?TNS_ADMIN=/full/path/to/Wallet_yourdb' @sql/03_enqueue_batch.sql
```

The Java process should print each message as it is dequeued:

```text
[2026-06-10T12:00:00Z] message #1 id=...
{"eventType":"ORDER_CREATED","orderId":1001,"customer":"stef","amount":42.50}
```

## Cleanup

```bash
sql 'aqdemo/<password>@yourdb_tp?TNS_ADMIN=/full/path/to/Wallet_yourdb' @sql/04_cleanup.sql
```

## Useful Environment Variables

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `DB_URL` | Yes | | JDBC URL, usually `jdbc:oracle:thin:@service?TNS_ADMIN=/wallet/path` |
| `DB_USER` | Yes | | Database username |
| `DB_PASSWORD` | Yes | | Database password |
| `AQ_QUEUE` | No | `ORDER_EVENTS_Q` | Queue name visible to the connected schema |
| `AQ_PAYLOAD_TYPE` | No | `RAW` | Payload type passed to the JDBC AQ API |
| `AQ_WAIT_SECONDS` | No | `30` | Dequeue wait timeout |
| `AQ_MAX_MESSAGES` | No | `0` | `0` means keep listening forever |

## Demo Flow

1. `DBMS_AQADM` creates and starts the queue.
2. SQL scripts enqueue JSON messages as `RAW`.
3. The Java app blocks on `OracleConnection.dequeue(...)`.
4. On each message, the consumer commits the dequeue and prints the payload.


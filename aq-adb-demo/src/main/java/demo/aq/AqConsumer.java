package demo.aq;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.Instant;
import java.util.HexFormat;
import java.util.Locale;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.aq.AQDequeueOptions;
import oracle.jdbc.aq.AQMessage;
import oracle.jdbc.pool.OracleDataSource;

public final class AqConsumer {
    private static final int ORA_AQ_TIMEOUT = 25228;

    private AqConsumer() {
    }

    public static void main(String[] args) throws Exception {
        Config config = Config.fromEnvironment();

        OracleDataSource dataSource = new OracleDataSource();
        dataSource.setURL(config.dbUrl());
        dataSource.setUser(config.dbUser());
        dataSource.setPassword(config.dbPassword());

        try (Connection jdbcConnection = dataSource.getConnection()) {
            jdbcConnection.setAutoCommit(false);
            OracleConnection connection = jdbcConnection.unwrap(OracleConnection.class);

            AQDequeueOptions options = new AQDequeueOptions();
            options.setWait(config.waitSeconds());

            System.out.printf(
                    "Listening on %s as %s. Wait=%ss, maxMessages=%s%n",
                    config.queueName(),
                    config.dbUser(),
                    config.waitSeconds(),
                    config.maxMessages() == 0 ? "unlimited" : config.maxMessages());

            int received = 0;
            while (config.maxMessages() == 0 || received < config.maxMessages()) {
                try {
                    AQMessage message = connection.dequeue(config.queueName(), options, config.payloadType());
                    jdbcConnection.commit();
                    received++;
                    printMessage(received, message);
                } catch (SQLException e) {
                    jdbcConnection.rollback();
                    if (e.getErrorCode() == ORA_AQ_TIMEOUT) {
                        System.out.printf("[%s] no message available after %s seconds%n",
                                Instant.now(), config.waitSeconds());
                        continue;
                    }
                    throw e;
                }
            }
        }
    }

    private static void printMessage(int count, AQMessage message) throws SQLException {
        byte[] payload = message.getPayload();
        String body = payload == null ? "" : new String(payload, StandardCharsets.UTF_8);
        String id = message.getMessageId() == null
                ? "(none)"
                : HexFormat.of().formatHex(message.getMessageId());

        System.out.printf("[%s] message #%d id=%s%n%s%n",
                Instant.now(), count, id, body);
    }

    private record Config(
            String dbUrl,
            String dbUser,
            String dbPassword,
            String queueName,
            String payloadType,
            int waitSeconds,
            int maxMessages) {

        static Config fromEnvironment() {
            String dbUrl = required("DB_URL");
            String dbUser = required("DB_USER");
            String dbPassword = required("DB_PASSWORD");
            String queueName = env("AQ_QUEUE", "ORDER_EVENTS_Q").toUpperCase(Locale.ROOT);
            String payloadType = env("AQ_PAYLOAD_TYPE", "RAW").toUpperCase(Locale.ROOT);
            int waitSeconds = positiveInt("AQ_WAIT_SECONDS", 30);
            int maxMessages = nonNegativeInt("AQ_MAX_MESSAGES", 0);

            return new Config(dbUrl, dbUser, dbPassword, queueName, payloadType, waitSeconds, maxMessages);
        }

        private static String required(String name) {
            String value = System.getenv(name);
            if (value == null || value.isBlank()) {
                throw new IllegalArgumentException("Missing required environment variable: " + name);
            }
            return value;
        }

        private static String env(String name, String defaultValue) {
            String value = System.getenv(name);
            return value == null || value.isBlank() ? defaultValue : value;
        }

        private static int positiveInt(String name, int defaultValue) {
            int value = nonNegativeInt(name, defaultValue);
            if (value < 1) {
                throw new IllegalArgumentException(name + " must be greater than zero");
            }
            return value;
        }

        private static int nonNegativeInt(String name, int defaultValue) {
            String value = System.getenv(name);
            if (value == null || value.isBlank()) {
                return defaultValue;
            }
            try {
                int parsed = Integer.parseInt(value);
                if (parsed < 0) {
                    throw new IllegalArgumentException(name + " must be zero or greater");
                }
                return parsed;
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(name + " must be an integer", e);
            }
        }
    }
}

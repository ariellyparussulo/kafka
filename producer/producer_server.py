import os
import json

from http.server import BaseHTTPRequestHandler, HTTPServer
from kafka import KafkaProducer
from kafka.errors import KafkaTimeoutError

bootstrap_servers = os.environ["BROKERS_URL"].split(",")
client_id = os.environ["CLIENT_ID"]
topic = os.environ["TOPIC"]
partition = os.environ["PARTITION"]

class Handler(BaseHTTPRequestHandler):
    """
        Producer HTTP Server Handler
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.producer = KafkaProducer(bootstrap_servers = bootstrap_servers, client_id = client_id)
        self.responses = {
            200: "Success",
            400: "Bad Request",
            401: "Unauthorized",
            403: "Forbidden",
            404: "Not Found",
            500: "Internal Server Error",
        }

    def get_content_length(self):
        """
            This method gets the Content-Length Header from the request and converts it to integer
        """
        content_length = self.headers.get("content-length")

        if content_length is None:
            return 0

        return int(content_length)

    def generate_response(self, status_code, message = None):
        """
            This method defines the response headers for this server and generates the JSON message for this response.
            If the message parameter is not provided, the method uses the default message mapped in the responses atrribute.
        """
        message = message if message else self.responses[status_code]
        message_json = json.dumps({
            "message": message
        })

        self.send_response(status_code)
        self.send_header("Content-type", "text/json")
        self.end_headers()

        self.wfile.write(message_json.encode("utf-8"))

    # pylint: disable=invalid-name
    def do_POST(self):
        """
            Handles POST request and send body message to a kafka cluster.
        """
        content_length = self.get_content_length()

        if content_length == 0:
            self.generate_response(400, "Invalid Input.")
            return

        body = self.rfile.read(content_length)

        try:
            self.producer.send(topic, partition = 0, key = "status", value = body)
            self.generate_response(200)
        except KafkaTimeoutError as error:
            print("Kafka Timeout Error. " + error)
            self.generate_response(500, "Unable to send message to topic.")


with HTTPServer(("localhost", 9000), Handler) as server:
    print("Listening port 9000...")
    server.serve_forever()

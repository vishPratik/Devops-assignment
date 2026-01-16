# app.py
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def home():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>DevSecOps Assignment</title>
        <style>
            body { font-family: Arial; text-align: center; padding: 50px; }
            .container { max-width: 800px; margin: 0 auto; }
            .success { color: green; font-weight: bold; }
            .info { background: #f0f0f0; padding: 20px; border-radius: 10px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 DevSecOps Assignment</h1>
            <p class="success">✅ Application is running successfully!</p>
            <div class="info">
                <h2>Project Details:</h2>
                <p><strong>Purpose:</strong> DevSecOps pipeline demonstration</p>
                <p><strong>Features:</strong> Docker, Terraform, Jenkins, Security Scanning</p>
                <p><strong>Status:</strong> Secure deployment pipeline implemented</p>
            </div>
            <p>Server Host: <strong>""" + os.environ.get('HOSTNAME', 'Local') + """</strong></p>
        </div>
    </body>
    </html>
    """

@app.route('/health')
def health():
    return {"status": "healthy", "service": "devops-webapp"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
    
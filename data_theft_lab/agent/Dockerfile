FROM python:3.9-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
# We need seed_emails.py inside the container to populate MailHog
COPY seed_emails.py .

CMD ["python", "agent.py"]

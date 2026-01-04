import smtplib
from email.message import EmailMessage
import time
import sys

SMTP_SERVER = "mailhog"
SMTP_PORT = 1025
TARGET_EMAIL = "user@internal.lab"

EMAILS = [
    {
        "subject": "Welcome to Internal Lab",
        "body": "Welcome to the team! Please set up your account."
    },
    {
        "subject": "Project X Update",
        "body": "The deadline for Project X has been moved to Friday."
    },
    {
        "subject": "Bank Account Details",
        "body": "Here are your account details for the transfer.\nBank: Chase\nAccount Number: 123456789\nSort Code: 11-22-33\nBalance: $50,000"
    },
    {
        "subject": "Security Alert",
        "body": "We noticed a login from a new device. Please verify."
    },
    {
        "subject": "Your IBAN Number",
        "body": "For international transfers, use this IBAN: US12345678901234567890\nSWIFT: CHASUS33"
    },
    {
        "subject": "Meeting Notes",
        "body": "Notes from the marketing meeting attached."
    },
    {
        "subject": "Reset Password",
        "body": "Click here to reset your password. Your temporary token is: SECURE_TOKEN_999"
    },
    {
        "subject": "Expense Report",
        "body": "Your expense report for March has been approved."
    },
    {
        "subject": "Secret Balance Sheet",
        "body": "CONFIDENTIAL: The Q1 balance sheet shows a surplus of $2M. Do not share."
    },
    {
        "subject": "Lunch?",
        "body": "Hey, do you want to grab lunch at 12?"
    }
]

def seed_emails():
    print(f"[*] Connecting to {SMTP_SERVER}:{SMTP_PORT}...")
    try:
        # Wait for Mailhog to be up
        time.sleep(5) 
        
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as s:
            for email_data in EMAILS:
                msg = EmailMessage()
                msg.set_content(email_data["body"])
                msg['Subject'] = email_data["subject"]
                msg['From'] = "admin@internal.lab"
                msg['To'] = TARGET_EMAIL
                
                s.send_message(msg)
                print(f"[+] Sent email: {email_data['subject']}")
                time.sleep(0.5)
        print("[*] Email seeding complete.")
    except Exception as e:
        print(f"[!] Failed to seed emails: {e}")
        sys.exit(1)

if __name__ == "__main__":
    seed_emails()

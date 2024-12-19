#!/bin/bash

# گرفتن اطلاعات از کاربر
read -p "Enter your email address: " email
read -p "Enter your server username (default: root): " username
read -p "Enter your server IP address: " server_ip
read -p "Enter your SSH port (default: 22): " ssh_port

# استفاده از مقادیر پیش‌فرض
username=${username:-root}
ssh_port=${ssh_port:-22}

# ایجاد کلید SSH
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""

# بررسی موفقیت کلید
if [ $? -ne 0 ]; then
  echo "Error generating SSH key."
  exit 1
fi

# کپی کردن کلید عمومی به سرور با استفاده از پورت مشخص‌شده
ssh-copy-id -i ~/.ssh/id_rsa.pub -p "$ssh_port" "$username@$server_ip"

# بررسی موفقیت کپی
if [ $? -eq 0 ]; then
  echo "SSH key successfully copied to the server."

  # اگر کاربر root است، بررسی دسترسی به فایل‌های روت
  if [ "$username" == "root" ]; then
    echo "You are logged in as root. Ensuring root access is configured correctly."

    # اطمینان از مجوزهای درست برای فایل authorized_keys
    ssh -p "$ssh_port" "$username@$server_ip" "chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys"

    if [ $? -eq 0 ]; then
      echo "Root access configured successfully."
    else
      echo "Failed to configure root access."
      exit 1
    fi
  fi
else
  echo "Error copying SSH key to the server."
  exit 1
fi

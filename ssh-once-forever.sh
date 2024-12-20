#!/bin/bash

# استفاده از پارامترهای ورودی (اگر داده شده باشد)
email=${1:-"your_email@example.com"}
username=${2:-"root"}
server_ips=${3:-"192.168.1.1"} # لیست پیش‌فرض IP یا دامنه سرورها
ssh_port=${4:-22}

# بررسی وجود کلید SSH و حذف آن در صورت وجود
if [ -f ~/.ssh/id_rsa ]; then
  echo "کلید SSH قبلی پیدا شد. در حال حذف آن..."
  rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
fi

# ایجاد کلید SSH
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""

# بررسی موفقیت کلید
if [ $? -ne 0 ]; then
  echo "Error generating SSH key."
  exit 1
fi

# تبدیل لیست سرورها به آرایه
IFS=',' read -ra servers <<< "$server_ips"

# برای هر سرور کلید SSH را کپی کن
for server_ip in "${servers[@]}"; do
  echo "کپی کردن کلید SSH به سرور $server_ip ..."
  
  # کپی کردن کلید عمومی به سرور
  ssh-copy-id -i ~/.ssh/id_rsa.pub -p "$ssh_port" "$username@$server_ip"

  # بررسی موفقیت کپی
  if [ $? -eq 0 ]; then
    echo "SSH key successfully copied to $server_ip."

    # اگر کاربر root است، بررسی دسترسی به فایل‌های روت
    if [ "$username" == "root" ]; then
      echo "You are logged in as root on $server_ip. Ensuring root access is configured correctly."

      # اطمینان از مجوزهای درست برای فایل authorized_keys
      ssh -p "$ssh_port" "$username@$server_ip" "chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys"

      if [ $? -eq 0 ]; then
        echo "Root access configured successfully on $server_ip."
      else
        echo "Failed to configure root access on $server_ip."
        exit 1
      fi
    fi
  else
    echo "Error copying SSH key to $server_ip."
    exit 1
  fi
done

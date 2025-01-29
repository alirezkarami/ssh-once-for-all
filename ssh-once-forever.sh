#!/bin/bash

# استفاده از پارامترهای ورودی (اگر داده شده باشد)
email=${1:-"your_email@example.com"}
username=${2:-"root"}
server_ip=${3:-"exe1.soft9988.ir"} # لیست پیش‌فرض IP یا دامنه سرورها
ssh_port=${4:-22}
host=${5:-"exe"}

[ -f ~/.ssh/config ] || touch ~/.ssh/config

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

echo "کپی کردن کلید SSH به سرور $server_ip ..."

# کپی کردن کلید عمومی به سرور
ssh-copy-id -i ~/.ssh/id_rsa.pub -p "$ssh_port" "$username@$server_ip"

if [ $? -eq 0 ]; then
  echo "SSH key successfully copied to $server_ip."
fi

echo "Host $host
      HostName $server_ip
      User $username
      Port $ssh_port
      IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config

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
else
  echo "Error copying SSH key to $server_ip."
  exit 1
fi
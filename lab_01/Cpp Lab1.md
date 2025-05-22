# Лабораторная работа 1: [C++ & UNIX]: UNIX знакомство: useradd, nano, chmod, docker, GIT, CI, CD

### Выполнил Подгорный Роман z3344 2025

## Цель: Познакомить студента с основами администрирования программных комплексов в ОС семейства UNIX, продемонстрировать особенности виртуализации и контейнеризации, продемонстрировать преимущества использования систем контроля версий (на примере GIT)

## **Часть 1: [ОС] Работа в ОС, использование файловой системы, прав доступа исполение файлов**
### **1.1. Создание директорий**
```bash
sudo mkdir -p /usr/local/folder_{max,min}
```
**Проверка:**
```bash
ls -ld /usr/local/folder_{max,min}
```
**Ответ:**
```
drwxr-xr-x 2 root root 4096 Мая 20 22:56 /usr/local/folder_max
drwxr-xr-x 2 root root 4096 Мая 20 22:58 /usr/local/folder_min
```

---

### **1.2. Создание групп**
```bash
sudo groupadd group_max && sudo groupadd group_min
```
**Проверка:**
```bash
getent group group_{max,min}
```
**Ответ:**
```
group_max:x:1001:
group_min:x:1002:
```

---

### **1.3. Создание пользователей**
```bash
sudo useradd -G group_max user_max_1 && sudo useradd -G group_min user_min_1
```
**Проверка:**
```bash
id user_max_1 && id user_min_1
```
**Ответ:**
```
uid=1001(user_max_1) gid=1001(user_max_1) groups=1001(user_max_1),1001(group_max)
uid=1002(user_min_1) gid=1002(user_min_1) groups=1002(user_min_1),1002(group_min)
```

---

### **1.4. Настройка прав**
```bash
sudo chown :group_max /usr/local/folder_max
sudo chown :group_max /usr/local/folder_min
sudo chmod 770 /usr/local/folder_max
sudo chmod 775 /usr/local/folder_min
sudo setfacl -Rm g:group_min:rwx /usr/local/folder_min
```
**Проверка:**
```bash
getfacl /usr/local/folder_min | grep "group_min"
```
**Ответ:**
```
group:group_min:rwx
```

---

### **1.5–1.8. Тестирование скриптов**
**1.5. Скрипт в `folder_max` (запись в текущую папку):**
```bash
sudo -u user_max_1 bash -c 'echo "date > /usr/local/folder_max/output.log" > /usr/local/folder_max/script.sh'
sudo -u user_max_1 bash -c 'chmod +x /usr/local/folder_max/script.sh && /usr/local/folder_max/script.sh'
```
**Проверка:**
```bash
sudo -u user_max_1 cat /usr/local/folder_max/output.log
```
**Результат:**
```bash
Ср 21 Мая 23:05:45 UTC
```
**1.6. Скрипт в `folder_max` (запись в папку min):**
```bash
sudo -u user_max_1 bash -c 'echo "date > /usr/local/folder_min/output.log" > /usr/local/folder_max/script_to_min.sh'
sudo -u user_max_1 bash -c 'chmod +x /usr/local/folder_max/script_to_min.sh && /usr/local/folder_max/script_to_min.sh'
```
**Проверка:**
```bash
sudo -u user_max_1 cat /usr/local/folder_min/output.log
```
**Результат:**
```bash
Вт 21 Мая 23:05:45 UTC
```
---

**1.7. Запуск скрипта из `folder_max` пользователем `user_min_1`:**
```bash
sudo -u user_min_1 /usr/local/folder_max/script_to_min.sh
```
**Результат:**  
`Permission denied`

---

**1.8. Запуск скрипта из `folder_min` пользователем `user_min_1`:**
```bash
sudo -u user_min_1 bash -c 'echo "date > /usr/local/folder_max/output.log" > /usr/local/folder_min/script_to_max.sh'  
sudo -u user_min_1 bash -c 'chmod +x /usr/local/folder_min/script_to_max.sh'  
sudo -u user_min_1 bash -c '/usr/local/folder_min/script_to_max.sh'
```
**Проверка:**  
```bash 
ls -l /usr/local/folder_max/output.log
```

**Результат:**
```bash 
bash: /usr/local/folder_min/script_to_max.sh: Permission denied
```
---

### **1.9. Итоговая проверка прав**
```bash
ls -la /usr/local/folder_max
ls -la /usr/local/folder_min
getfacl /usr/local/folder_max
getfacl /usr/local/folder_min
```
**Ответ:**
```bash
drwxrwx--- 2 root group_max 4096 May 23 12:00 /usr/local/folder_max  
drwxrwxr-x+ 2 root group_max 4096 May 23 12:00 /usr/local/folder_min  

# file: /usr/local/folder_max  
# owner: root  
# group: group_max  
user::rwx  
group::rwx  
other::---  

# file: /usr/local/folder_min  
# owner: root  
# group: group_max  
user::rwx  
group::rwx  
group:group_min:rwx  
mask::rwx  
other::r-x
```
---

## **Часть 2: Docker**
### **2.1–2.2. Создание образа**
```bash
echo -e '#!/bin/bash\ndate > output.log' > script.sh
echo -e 'FROM alpine:latest\nRUN apk add --no-cache nano\nCOPY script.sh /script.sh\nCMD ["/bin/sh"]' > Dockerfile
docker build -t my_image .
```
**Проверка:**
```bash
docker images | grep my_image
```
**Результат:**
```bash
my_image   latest   abc123   5 minutes ago   10MB
```

---

### **2.3–2.5. Запуск контейнера**
```bash
docker run -itd --name my_container my_image
docker exec my_container /script.sh
docker exec my_container cat /output.log
```
**Ответ:**
```
Ср Мая 21 23:20:12 UTC
```

---

## **Часть 3: Git**
### **3.1–3.3. Настройка репозитория**
```bash
mkdir -p lab_01/{build,src,doc,cmake}
mkdir -p lab_02/{build,src,doc,cmake}
git add lab_01 lab_02
git commit -m "feat: created lab_01 and lab_02"
git push
git checkout -b stg
git push -u origin stg

git checkout dev

git checkout -b prd
git push -u origin prd

git checkout dev
```

### **3.4-3.5 Скрипты**
```bash
cat > sync_dev_to_stg.sh << 'EOF'
#!/bin/bash

git checkout stg 


git merge dev --no-ff -m "Auto-merge from dev on $(date +'%Y-%m-%d %H:%M:%S')"

TAG="merge-$(date +%Y%m%d-%H%M%S)"
git tag "$TAG"

git push origin stg
git push origin "$TAG"
EOF

chmod +x sync_dev_to_stg.sh
```
И аналогично:
```bash
cat > sync_stg_to_dev.sh << 'EOF'
#!/bin/bash

git checkout dev 

...

chmod +x sync_stg_to_dev.sh
```


---

## **Заключение**
- Понял, что какая-то координация из CMD удобна: быстро, просто распределять права, доступы
- Удобно создавать файлы прямо в консоли
- Работать с Git из консоли очень неудобно
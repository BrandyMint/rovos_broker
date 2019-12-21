# Rovos-HTTP брокер.

Представляет из себя объеиненный TCP и HTTP сревер. Предоствляет REST протокол
для общения с вендинговым аппаратом.

# Запуск сервера

> bundle exec rackup

# Команды

## Состояние брокера

> curl http://localhost:8080/

## Сколько и какие машины в подключении

> curl http://localhost:8080/machines/

## Получить статус машины (время последней активности)

> curl http://localhost:8080/machines/:id

Например:

> curl http://localhost:8080/machines/100020003

## Изменить режим (состояние) работы машины

> curl -XPOST http://localhost:8080/machines/100020003?state=СОСТОЯНИЕ&work_time=ВРЕМЯ________В___МИНУТАХ

Например включить машину в режим "Стандартный массаж" на 2 минуты:

> curl -XPOST http://localhost:8080/machines/100020003?state=2&work_time=4

## Режимы работы машины

* 0 - Аппарат загружается
* 1 - Кресло в режиме ожидания команды
* 2 - Стандартный массаж (на указанное количество времени)
* 3 - Не известный
* 4 - Запрос состояния вендинговой машины
* 5 - Разбудить тело (зарезервированная функция)
* 6 - Передача Ци и Крови (зарезервированная функция)
* 7 - Диастола (зарезервированная функция)
* 8 - Массаж талии (зарезервированная функция)
* 9 - Массаж шеи (зарезервированная функция)
* 255 - Сброс (в режиме сброса). Сбрасывает оставшееся время (`elapsed_time`)
  если оно было закинуто в 65536. Не влияет на уже запущенную машину.

## Установка systemd-демона на боемов

> sudo bundle exec foreman export --app rovos-broker --user wwwuser systemd /etc/systemd/system

## Ограничение доступа

Доступ огранчивается на уровне фронт-веб-сервера. Например через индивидуальный сертификат на caddy:

Делаем по инструкции https://gist.github.com/Soarez/9688998

> openssl genrsa -out broker.venpay.ru.key 2048  # Может лишнее, не помню уже
> openssl req -new -key broker.venpay.ru.key -out broker.venpay.ru.csr  
> openssl req -in broker.venpay.ru.csr -noout -text 
> openssl genrsa -out ca.key 2048
> openssl req -new -x509 -key ca.key -out ca.crt 
> openssl x509 -req -in broker.venpay.ru.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out broker.venpay.ru.crt
> cat broker.venpay.ru.crt ca.crt > broker.venpay.ru.bundle.crt 
> scp broker.venpay.ru.bundle.crt wwwuser@venpay.ru:/home/wwwuser/venpay.ru/shared/config/
> scp broker.venpay.ru.key wwwuser@venpay.ru:/home/wwwuser/venpay.ru/shared/config/
> scp broker.venpay.ru.pub wwwuser@venpay.ru:/home/wwwuser/venpay.ru/shared/config/
> scp ca.*  wwwuser@venpay.ru:/home/wwwuser/venpay.ru/shared/config/
> cat broker.venpay.ru.key >> broker.venpay.ru.pem 

Тестируем:

> curl -k https://broker.venpay.ru/machines --cert ./broker.venpay.ru.pem

или

> curl -k https://broker.venpay.ru/machines --cert ./broker.venpay.ru.pem \
  --cacert ./ca.pem --key ./broker.venpay.ru.key

В `Caddyfile`:

```
broker.venpay.ru {
  log /tmp/caddy_broker.venpay.ru.access.log
  errors /tmp/caddy_broker.venpay.ru.error.log
  gzip

  tls /home/wwwuser/venpay.ru/shared/config/certs/broker.venpay.ru.bundle.crt /home/wwwuser/venpay.ru/shared/config/certs/broker.venpay.ru.key {
    clients  /home/wwwuser/venpay.ru/shared/config/certs/ca.crt
    max_certs 10
  }

  header / -Server

  proxy / http://localhost:8080 {
    transparent
    websocket
  }
}
```

## TODO

* https://www.codebasehq.com/blog/ruby-threads-queue

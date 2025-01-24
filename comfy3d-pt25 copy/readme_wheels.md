# Инструкция по установке Pre-Built Wheels

Этот документ описывает процесс установки pre-built wheels для ComfyUI 3D Pack в Docker-контейнере.

## Структура системы

- `install-wheels.sh` - скрипт для управления установкой wheels
- Wheels монтируются из `../Comfy3D_Pre_Builds/_Build_Wheels` в `/wheels` внутри контейнера
- Поддерживаются различные конфигурации для разных версий Python, PyTorch и CUDA

## Важно о совместимости CUDA

Убедитесь, что версия CUDA в wheels соответствует версии драйверов на хост-машине:
- Если у вас драйверы CUDA 12.1 - используйте wheels с `cu121`
- Если у вас драйверы CUDA 11.8 - используйте wheels с `cu118`
и т.д.

## Команды управления

### 1. Просмотр доступных конфигураций
```bash
docker-compose exec comfyui /runner-scripts/install-wheels.sh list
```

### 2. Автоматическое определение и установка
```bash
docker-compose exec comfyui /runner-scripts/install-wheels.sh auto
```

### 3. Установка конкретной конфигурации
```bash
docker-compose exec comfyui /runner-scripts/install-wheels.sh py312_torch2.5.0_cu121
```

## Примеры использования

1. Для CUDA 12.1:
```bash
# Установка wheels для Python 3.12 + PyTorch 2.5.0
docker-compose exec comfyui /runner-scripts/install-wheels.sh py312_torch2.5.0_cu121

# Или для Python 3.12 + PyTorch 2.4.0
docker-compose exec comfyui /runner-scripts/install-wheels.sh py312_torch2.4.0_cu121
```

2. Для CUDA 11.8:
```bash
# Установка wheels для Python 3.12 + PyTorch 2.4.0
docker-compose exec comfyui /runner-scripts/install-wheels.sh py312_torch2.4.0_cu118
```

## Устранение проблем

1. Если автоматическое определение не работает:
   - Проверьте вывод команды `list` для доступных конфигураций
   - Выберите конфигурацию, соответствующую вашей версии CUDA

2. При ошибках установки:
   - Убедитесь, что версия CUDA соответствует драйверам на хосте
   - Попробуйте другую совместимую версию PyTorch
   - Проверьте наличие wheels в указанной директории

## Обновление wheels

Для обновления wheels:
1. Остановите контейнер: `docker-compose down`
2. Обновите содержимое папки `Comfy3D_Pre_Builds`
3. Запустите контейнер: `docker-compose up -d`
4. Выполните установку нужной конфигурации wheels

## Дополнительная информация

- Wheels монтируются в режиме "только чтение" (`:ro`)
- Скрипт использует `pip install --force-reinstall` для обновления пакетов
- Конфигурация контейнера настроена на использование CUDA 12.1 
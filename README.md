# Implantação Automatizada do PostgreSQL

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ansible](https://img.shields.io/badge/Ansible-2.9%2B-blue.svg)](https://www.ansible.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.x-316192.svg)](https://www.postgresql.org/)

## 📋 Sobre o Projeto

Este playbook Ansible automatiza a instalação e configuração do PostgreSQL 16 em múltiplos ambientes (DEV, STG e PROD). Ele foi projetado para garantir instalações padronizadas, seguras e reproduzíveis.

### ✨ Características Principais

- 🚀 **Instalação automatizada** do PostgreSQL 16
- 🔐 **Configuração segura** com usuários administrativos e de aplicação
- 🔥 **Configuração automática de firewall**
- 🎯 **Suporte a múltiplos ambientes** (DEV, STG, PROD)
- ✅ **Modo check** para validação prévia (dry-run)
- 🧪 **Ambiente de desenvolvimento** com Vagrant

> **📦 Status**: Atualmente estruturado como playbook Ansible, com planos para migração futura para **Ansible Collection**.

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📋 Índice

- [Requisitos](#-requisitos)
- [Início Rápido](#-início-rápido)
- [Ambientes Suportados](#️-ambientes-suportados)
- [Configuração de Variáveis](#️-configuração-de-variáveis)
- [Gestão de Senhas (Ansible Vault)](#-gestão-de-senhas-ansible-vault)
- [Instalação](#-instalação)
- [Desinstalação](#️-desinstalação)
- [Usuários do PostgreSQL](#-usuários-do-postgresql)
- [Conectividade](#-conectividade)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Contribuindo](#-contribuindo)
- [Roadmap](#-roadmap)
- [Convenção de Mensagens de Commit](#-convenção-de-mensagens-de-commit)

## 🔧 Requisitos

### Controlador Ansible (máquina local)
- Ansible 2.9 ou superior
- Python 3.6+
- Vagrant 2.0+ e VirtualBox 6.0+ (opcional, apenas para DEV)

### Servidores Alvo
- Oracle Linux / RHEL / AlmaLinux / Rocky Linux 9.x
- Acesso SSH configurado
- Usuário com privilégios sudo
- Conexão com a internet

## 🚀 Início Rápido

### 1. Configuração e Criptografia de Senhas (Ansible Vault)

Este projeto utiliza **Ansible Vault** para proteger credenciais. As senhas **nunca** são commitadas no repositório.

#### Setup Inicial

```bash

# 1. Copiar templates de vault
cp inventories/stg/group_vars/postgres/vault.yml.example inventories/stg/group_vars/postgres/vault.yml


# 2. Editar com suas senhas reais
vi inventories/stg/group_vars/postgres/vault.yml

# 3. Criar senha master do vault
echo "sua-senha-master-forte" > .vault_pass
chmod 600 .vault_pass


# 4. Criptografar o arquivo
ansible-vault encrypt inventories/stg/group_vars/postgres/vault.yml --vault-password-file .vault_pass
```

#### Uso no Dia a Dia

```bash
# Executar playbook com vault
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass \
  --ask-become-pass


# Ver arquivo criptografado
ansible-vault view inventories/stg/group_vars/postgres/vault.yml --vault-password-file .vault_pass

# Editar arquivo criptografado
ansible-vault edit inventories/stg/group_vars/postgres/vault.yml --vault-password-file .vault_pass
```

### 2. Executar o Projeto

#### Desenvolvimento Local (Vagrant)

```bash
# Clone o repositório
git clone https://github.com/Jefferson682/ansible-postgresql.git
cd ansible-postgresql

# Inicie o ambiente
vagrant up
ansible-playbook -i inventories/dev/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass
```

#### Staging/Produção

```bash
# 1. Configure o SSH
ssh-copy-id ansible_user@<IP>

# 2. Teste (recomendado)
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass \
  --check \
  --ask-become-pass

# 3. Execute
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass \
  --ask-become-pass
```

## 🖥️ Ambientes Suportados

### Sistemas Operacionais
- ✅ Oracle Linux 9.x
- ✅ Red Hat Enterprise Linux 9.x
- ✅ AlmaLinux 9.x
- ✅ Rocky Linux 9.x
- ✅ Ubuntu 24.04 LTS

### Versão PostgreSQL
- ✅ PostgreSQL 16.x (recomendada e testada)

### Recursos Implementados
- ✅ Instalação standalone completa
- ✅ Múltiplos ambientes (DEV, STG, PROD)
- ✅ Criação automática de usuários e banco
- ✅ Configuração de firewall
- ✅ Modo check (dry-run)
- ✅ Idempotência

### Limitações
- ❌ Cluster de alta disponibilidade
- ❌ Replicação master/slave
- ❌ Backup automático
- ❌ SSL/TLS automático

## ⚙️ Configuração de Variáveis

### Estrutura de Variáveis e Vault

O projeto segue o padrão de organização de variáveis e arquivos vault conforme a estrutura de `stg` (que deve ser replicada para `dev` e `prod`):

- **Variáveis e secrets por ambiente:**
  - Local: `inventories/[ambiente]/group_vars/postgres/main.yml` (variáveis)
  - Local: `inventories/[ambiente]/group_vars/postgres/vault.yml` (secrets criptografados)
  - Exemplo: `inventories/[ambiente]/group_vars/postgres/vault.yml.example`
  - Use sempre este padrão para DEV, STG e PROD.

Principais variáveis:
- `postgres_version: 16` - Versão do PostgreSQL
- `postgres_port: 5432` - Porta padrão
- `postgres_superuser: postgres` - Superusuário padrão
- `postgres_admin_user: db_admin` - Usuário DBA
- `postgres_data_dir: /opt/psql` - Diretório de dados
- `postgres_app_user` - Usuário da aplicação
- `postgres_app_user_readonly` - Usuário read-only (opcional)
- `postgres_app_db` - Nome do banco de dados

## 🔐 Gestão de Senhas (Ansible Vault)

Este projeto utiliza **Ansible Vault** para proteger credenciais. As senhas **nunca** são commitadas no repositório.

### Setup Inicial

```bash
# 1. Copiar templates de vault
cp group_vars/vault.yml.example group_vars/vault.yml
cp inventories/stg/group_vars/vault.yml.example inventories/stg/group_vars/vault.yml

# 2. Editar com suas senhas reais
vi group_vars/vault.yml
vi inventories/stg/group_vars/vault.yml

# 3. Criar senha master do vault
echo "sua-senha-master-forte" > .vault_pass
chmod 600 .vault_pass

# 4. Criptografar os arquivos
ansible-vault encrypt group_vars/vault.yml --vault-password-file .vault_pass
ansible-vault encrypt inventories/stg/group_vars/vault.yml --vault-password-file .vault_pass
```

### Uso no Dia a Dia

```bash
# Executar playbook com vault
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass \
  --ask-become-pass

# Ver arquivo criptografado
ansible-vault view group_vars/vault.yml --vault-password-file .vault_pass

# Editar arquivo criptografado
ansible-vault edit group_vars/vault.yml --vault-password-file .vault_pass
```

## 🚀 Instalação

### Desenvolvimento
```bash
vagrant up
ansible-playbook -i inventories/dev/inventory.ini playbooks/install_postgres.yml
```

### Staging/Produção
```bash
# 1. Configure o SSH
ssh-copy-id ansible_user@<IP>

# 2. Teste (recomendado)
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass \
  --check \
  --ask-become-pass

# 3. Execute
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml \
  --vault-password-file .vault_pass \
  --ask-become-pass
```

💡 Use `--check --diff` para ver mudanças antes de aplicar.

## 🗑️ Desinstalação

Remove **completamente** o PostgreSQL (pacotes, dados, configurações):

```bash
# Desenvolvimento
ansible-playbook -i inventories/dev/inventory.ini playbooks/uninstall_postgres.yml

# Staging/Produção
ansible-playbook -i inventories/stg/inventory.ini playbooks/uninstall_postgres.yml --ask-become-pass
```

### ⚠️ ATENÇÃO - Operação Destrutiva!

Esta ação é **irreversível** e remove:
- ✓ Todos os pacotes PostgreSQL
- ✓ Diretório de dados (`/opt/psql`)
- ✓ Todas as configurações
- ✓ Usuário postgres do sistema
- ✓ Regras de firewall

**Faça backup antes de executar em produção!**

## 👥 Usuários do PostgreSQL

O playbook cria automaticamente 4 tipos de usuários com diferentes níveis de acesso:

### 1. `postgres` - Superusuário Padrão
- **Tipo**: Superusuário do PostgreSQL (criado automaticamente na instalação)
- **Uso**: **Apenas para emergências**
- **Permissões**: Acesso total ao PostgreSQL
- **⚠️ Importante**: Não use este usuário para operações rotineiras

### 2. `db_admin` - Administrador DBA
- **Tipo**: Administrador customizado para o DBA
- **Uso**: Administração diária do banco de dados
- **Permissões**: CREATEDB, CREATEROLE, SUPERUSER
- **Responsabilidades**:
  - Criar/remover databases
  - Gerenciar usuários
  - Ajustar configurações
  - Executar manutenções

### 3. `app_user_[ambiente]` - Usuário da Aplicação
- **Tipo**: Usuário proprietário do banco de dados
- **Uso**: Conexão da aplicação ao banco
- **Permissões**: Acesso total **apenas ao banco da aplicação**
- **Pode**: Criar/modificar/deletar tabelas, inserir/atualizar dados
- **Não pode**: Criar outros databases, gerenciar usuários

### 4. `app_user_[ambiente]_ro` - Usuário Read-Only (Opcional)
- **Tipo**: Usuário de leitura
- **Uso**: Relatórios, BI, analytics, consultas
- **Permissões**: SELECT em todas as tabelas do banco da aplicação
- **Não pode**: Inserir, atualizar ou deletar dados
- **Automático**: Tem acesso a tabelas futuras criadas pelo `app_user` ou `db_admin`

## 🔗 Conectividade

### Exemplos de Conexão

```bash
# DBA Admin
psql -h <IP> -p 5432 -U db_admin -d postgres

# Aplicação (staging)
psql -h 192.168.1.10 -p 5432 -U app_user_stg -d myapp_staging

# Read-only (para relatórios)
psql -h 192.168.1.10 -p 5432 -U app_user_stg_ro -d myapp_staging

# Teste de conectividade
nc -zv <IP> 5432
telnet <IP> 5432
```

## 💾 Armazenamento

### Padrão
- Caminho: `/opt/psql`
- Proprietário: `postgres:postgres`
- Permissões: `0700`

### Recomendação para STG/PROD
Use **volume separado** para `/opt/psql`:

**Benefícios:**
- ⚡ Performance otimizada
- 🔒 Isolamento de dados
- 💾 Backups facilitados
- 🛡️ Proteção do filesystem raiz

## 📊 Modo Check (Dry-Run)

Simula execução sem fazer mudanças:

```bash
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml --check --diff
```

### Interpretação
- ✅ **ok**: Estado já correto
- 🟡 **changed**: Seria modificado
- ⏭️ **skipped**: Pulado por condição
- ❌ **failed**: Erro que precisa correção

## 📁 Estrutura do Projeto

```
ansible-postgresql/
├── ansible.cfg
├── galaxy.yml                     # Metadados para Collection (futuro)
├── LICENSE
├── README.md
├── Vagrantfile
├── playbooks/
│   ├── install_postgres.yml
│   └── uninstall_postgres.yml
├── group_vars/
│   └── postgres/                  # (opcional, para variáveis globais)
│       ├── main.yml
│       ├── vault.yml.example
├── inventories/
│   ├── dev/
│   ├── stg/
│   │   └── group_vars/
│   │       └── postgres/
│   │           ├── main.yml           # Variáveis específicas do ambiente
│   │           ├── vault.yml          # Arquivo criptografado com Ansible Vault
│   │           └── vault.yml.example  # Exemplo de configuração para o Vault
│   └── prd/
└── roles/
    └── postgres/
        ├── tasks/
        ├── handlers/
        └── vars/
```

## 🤝 Contribuindo

Contribuições são bem-vindas!

1. Fork o repositório
2. Crie uma branch (`git checkout -b feature/MinhaFeature`)
3. Commit (`git commit -m 'Adiciona MinhaFeature'`)
4. Push (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request


## 📝 Convenção de Mensagens de Commit

Este projeto segue uma convenção de mensagens de commit para garantir clareza e consistência no histórico do Git.

### 🎯 **Formato da Mensagem de Commit**

```
<tipo>(escopo opcional): mensagem
```

### **Tipos Válidos**
- `feat`: Adição de nova funcionalidade
- `fix`: Correção de bugs
- `docs`: Alterações na documentação
- `style`: Alterações de estilo (formatação, etc.)
- `refactor`: Refatoração de código (sem novas funcionalidades ou correções de bugs)
- `test`: Adição ou correção de testes
- `chore`: Tarefas gerais (ex.: atualização de dependências)

### **Exemplos**

- `feat: adiciona suporte a múltiplos ambientes`
- `fix: corrige erro na configuração do firewall`
- `docs(readme): atualiza instruções de instalação`
- `style: ajusta indentação no playbook`
- `refactor(tasks): simplifica lógica de criação de usuários`
- `test: adiciona testes para validação de senhas`
- `chore: atualiza dependências do Ansible`

### 🚨 **Validação Automática**

Um hook Git (`commit-msg`) foi configurado para validar mensagens de commit. Se a mensagem não seguir o formato correto, o commit será rejeitado.

#### **Erro Exemplo**

Se você receber o seguinte erro:

```
ERRO: Formato de mensagem de commit inválido!
Formato esperado: <tipo>(escopo opcional): mensagem
```

Certifique-se de que sua mensagem segue o formato descrito acima.

#### **Desativar Temporariamente o Hook**

Se necessário, você pode ignorar o hook usando a flag `--no-verify`:

```bash
git commit --no-verify -m "mensagem fora do padrão"
```

## 📝 Roadmap

### ✅ Implementado
- [x] PostgreSQL 16.x
- [x] Oracle Linux / RHEL 9.x
- [x] Criação automática de banco e usuários
- [x] Usuário read-only com acesso a tabelas futuras
- [x] Firewall automático
- [x] Ansible Vault para senhas
- [x] Modo check (dry-run)
- [x] Múltiplos ambientes (DEV, STG, PROD)
- [x] Vagrant para desenvolvimento
- [x] Playbook de desinstalação

### 🚧 Planejado
- [ ] Ansible Collection
- [ ] PostgreSQL 15.x e 17.x
- [ ] Replicação streaming
- [ ] Alta disponibilidade (Patroni)
- [ ] Backup automático
- [ ] Monitoramento (Prometheus)
- [ ] SSL/TLS
- [ ] Performance tuning
- [ ] Extensões (PostGIS, TimescaleDB)

## 🔐 Segurança

### Implementado
- ✅ Ansible Vault para credenciais
- ✅ Firewall configurado automaticamente
- ✅ Princípio de menor privilégio por usuário
- ✅ Autenticação md5 para conexões remotas
- ✅ Usuário read-only para consultas
- ✅ Suporte a Ubuntu 24.04 LTS

### Recomendações
- 🔑 **Senhas fortes**: Use geradores de senha
- 🔐 **SSL/TLS**: Configure em produção
- 🛡️ **Firewall**: Limite IPs permitidos
- 📝 **Auditoria**: Monitore logs do PostgreSQL
- 🔄 **Rotação**: Altere senhas periodicamente
- 💾 **Backup**: Configure backups regulares
- 🚫 **postgres user**: Nunca use em operações rotineiras

## 📞 Suporte | Reportar Issues

- **Issues**: [GitHub Issues](https://github.com/Jefferson682/ansible-postgresql/issues)
- **Discussões**: [GitHub Discussions](https://github.com/Jefferson682/ansible-postgresql/discussions)
- **Autor**: José Jefferson Nascimento do Vale - [@Jefferson682](https://github.com/Jefferson682)

## ⭐ Agradecimentos

Se este projeto foi útil, considere dar uma ⭐!

---

**Desenvolvido com ❤️ pela comunidade DevOps**

# PostgreSQL Automated Deployment

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ansible](https://img.shields.io/badge/Ansible-2.9%2B-blue.svg)](https://www.ansible.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.x-316192.svg)](https://www.postgresql.org/)

## 📋 Sobre o Projeto

Este playbook Ansible automatiza a instalação e configuração do PostgreSQL 16 em múltiplos ambientes (DEV, STG e PROD). Criado para instalações padronizadas, seguras e reproduzíveis.

### ✨ Características Principais

- 🚀 **Instalação automatizada** do PostgreSQL 16
- 🔐 **Configuração segura** com usuários administrativos e de aplicação
- 🔥 **Firewall configurado** automaticamente
- 🎯 **Múltiplos ambientes** (DEV, STG, PROD)
- ✅ **Modo check** para validação prévia (dry-run)
- 🧪 **Ambiente de desenvolvimento** com Vagrant

> **📦 Status**: Atualmente estruturado como playbook Ansible, será migrado para **Ansible Collection** no futuro.

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📋 Índice

- [Requisitos](#-requisitos)
- [Início Rápido](#-início-rápido)
- [Ambientes Suportados](#️-ambientes-suportados)
- [Configuração](#️-configuração-de-variáveis)
- [Instalação](#-instalação)
- [Desinstalação](#️-desinstalação)
- [Usuários e Conectividade](#-usuários-e-conectividade)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Contribuindo](#-contribuindo)
- [Roadmap](#-roadmap)

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

### Desenvolvimento Local (Vagrant)

```bash
# Clone o repositório
git clone https://github.com/Jefferson682/ansible-postgresql.git
cd ansible-postgresql

# Inicie o ambiente
vagrant up
ansible-playbook -i inventories/dev/inventory.ini playbooks/install_postgres.yml
```

### Servidor Remoto

```bash
# 1. Configure SSH
ssh-copy-id ansible_user@<IP_DO_SERVIDOR>

# 2. Teste (dry-run)
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml --check --ask-become-pass

# 3. Execute
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml --ask-become-pass
```

## 🖥️ Ambientes Suportados

### Sistemas Operacionais
- ✅ Oracle Linux 9.x
- ✅ Red Hat Enterprise Linux 9.x
- ✅ AlmaLinux 9.x
- ✅ Rocky Linux 9.x

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

## 🌐 Estrutura de Inventários

| Ambiente | Descrição | Exemplo Host | Exemplo IP |
|----------|-----------|--------------|------------|
| **DEV** | Desenvolvimento (Vagrant) | postgres-lab | 127.0.0.1 |
| **STG** | Staging/Homologação | postgres-stg-hostname | 192.168.1.10 |
| **PRD** | Produção | postgres-prd-hostname | 10.0.1.100 |

> Configure os inventários em `inventories/[ambiente]/inventory.ini` com seus dados reais.

## ⚙️ Configuração de Variáveis

### Globais (`group_vars/default.yml`)
- `postgres_version: 16`
- `postgres_port: 5432`
- Usuários administrativos

### Por Ambiente (`inventories/[ambiente]/group_vars/postgres.yml`)
- `postgres_data_dir: /opt/psql`
- `postgres_app_user`: Usuário da aplicação
- `postgres_app_password`: Senha da aplicação
- `postgres_app_db`: Nome do banco

**⚠️ IMPORTANTE**: Use Ansible Vault para senhas. Nunca commite credenciais!

## 🚀 Instalação

### Desenvolvimento
```bash
vagrant up
ansible-playbook -i inventories/dev/inventory.ini playbooks/install_postgres.yml
```

### Staging/Produção
```bash
# 1. Configure SSH
ssh-copy-id ansible_user@<IP>

# 2. Teste (recomendado)
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml --check --ask-become-pass

# 3. Execute
ansible-playbook -i inventories/stg/inventory.ini playbooks/install_postgres.yml --ask-become-pass
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

## 👥 Usuários e Conectividade

### Usuários Criados Automaticamente

1. **postgres** - Superusuário padrão do PostgreSQL
2. **db_admin** - Admin customizado (SUPERUSER, CREATEDB, CREATEROLE)
3. **app_user_[ambiente]** - Usuário da aplicação (CREATEDB, LOGIN)

### Conectividade

```bash
# Admin
psql -h <IP> -p 5432 -U db_admin -d postgres

# Aplicação
psql -h <IP> -p 5432 -U app_user_stg -d myapp_staging

# Teste de porta
nc -zv <IP> 5432
```

### Responsabilidades do DBA

Após a instalação:
- Criar usuários adicionais
- Configurar usuários read-only
- Ajustar políticas de segurança
- Configurar backups
- Monitorar performance

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
│   └── default.yml
├── inventories/
│   ├── dev/
│   ├── stg/
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

### Reportar Issues
[GitHub Issues](https://github.com/Jefferson682/ansible-postgresql/issues)

## 📝 Roadmap

### ✅ Implementado
- [x] PostgreSQL 16.x
- [x] Oracle Linux / RHEL 9.x
- [x] Criação de banco e usuários
- [x] Firewall automático
- [x] Modo check
- [x] Múltiplos ambientes
- [x] Vagrant DEV
- [x] Playbook de desinstalação

### 🚧 Planejado
- [ ] Ansible Collection
- [ ] PostgreSQL 15.x e 17.x
- [ ] Replicação streaming
- [ ] Alta disponibilidade (Patroni)
- [ ] Backup automático
- [ ] Monitoramento (Prometheus)
- [ ] SSL/TLS
- [ ] Ubuntu/Debian
- [ ] Performance tuning
- [ ] Extensões (PostGIS, TimescaleDB)

## 🔐 Segurança

### Implementado
- ✅ Senhas não no código
- ✅ Firewall automático
- ✅ Princípio de menor privilégio
- ✅ Autenticação md5

### Recomendações
- 🔑 Use Ansible Vault
- 🔐 Configure SSL/TLS em produção
- 🛡️ Limite acesso via firewall
- 📝 Audite logs regularmente
- 🔄 Rotacione senhas
- 💾 Backups regulares

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/Jefferson682/ansible-postgresql/issues)
- **Discussões**: [GitHub Discussions](https://github.com/Jefferson682/ansible-postgresql/discussions)
- **Autor**: José Jefferson Nascimento do Vale - [@Jefferson682](https://github.com/Jefferson682)

## ⭐ Agradecimentos

Se este projeto foi útil, considere dar uma ⭐!

---

**Desenvolvido com ❤️ pela comunidade DevOps**

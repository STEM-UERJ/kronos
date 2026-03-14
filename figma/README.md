# Kronos UI (Figma)

Este diretório contém a interface do Kronos em formato web (Vite + React). Você pode rodar localmente para visualizar a UI e, opcionalmente, gerar um pacote de plugin para carregar no Figma.

---

## ✅ Rodando em modo de desenvolvimento

Execute os comandos abaixo no terminal:

```bash
cd c:\Users\Daniel\devs\Flutter\kronos\figma\ui
npm install
npm run dev
```

Depois de iniciado, o Vite exibirá algo como:

```
VITE v6.3.5  ready in 1181 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

Abra o link `http://localhost:5173` no navegador para ver a interface.

---

## 🧩 Gerar pacote de plugin Figma (opcional)

Para gerar um pacote que pode ser importado como um plugin Figma:

```bash
npm run build:figma
```

Depois, importe no Figma via:

**Plugins → Development → Import plugin from manifest...**

Selecione `figma/ui/dist/figma/manifest.json`.

---

## 🚀 Onde encontrar a saída do build

- UI gerada: `figma/ui/dist/figma/ui.html`
- Manifest do plugin: `figma/ui/dist/figma/manifest.json`
- Código principal do plugin: `figma/ui/dist/figma/code.js`

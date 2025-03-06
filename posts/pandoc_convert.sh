#!/bin/bash

# Demande à l'utilisateur le chemin du fichier Markdown
read -p "Entrez le chemin du fichier Markdown : " markdown_file

# Vérifie si le fichier Markdown existe
if [ ! -f "$markdown_file" ]; then
  echo "Le fichier Markdown '$markdown_file' n'existe pas. Abandon."
  exit 1
fi

# Demande à l'utilisateur le chemin du template HTML
read -p "Entrez le chemin du template HTML : " template_file

# Vérifie si le template existe
if [ ! -f "$template_file" ]; then
  echo "Le fichier template '$template_file' n'existe pas. Abandon."
  exit 1
fi

# Demande à l'utilisateur le nom du fichier de sortie
read -p "Entrez le nom du fichier de sortie : " output_file

# Exécute Pandoc avec les paramètres fournis
pandoc "$markdown_file" -o "$output_file" --template="$template_file"

# Informe l'utilisateur que la conversion est terminée
echo "Conversion terminée : '$output_file' a été généré avec succès."

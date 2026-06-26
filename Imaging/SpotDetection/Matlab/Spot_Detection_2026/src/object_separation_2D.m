function [label_mask] = object_separation_2D(mask,rad,gray_img)
% OBJECT_SEPARATION_2D - Version robuste simplifiée
%
% Objectif : éviter toute sur-segmentation des noyaux.
% Suppression complète du watershed agressif.
% Utilise uniquement morphologie + filtrage par taille.

if (max(mask) > 0)

    mask = squeeze(mask > 0);
    dim = length(size(mask));

    % Projection 2D si nécessaire
    if dim > 2
        mask2D = squeeze(sum(mask,[],3)) > 0;
    else
        mask2D = mask;
    end

    % -----------------------------
    % 🔵 Nettoyage morphologique doux
    % -----------------------------
    
    % Fermeture pour combler petites fissures internes
    mask2D = bclosing(mask2D, round(rad/3));

    % Ouverture légère pour enlever petits artefacts
    mask2D = bopening(mask2D, round(rad/4));

    % -----------------------------
    % 🔵 Labelisation simple
    % -----------------------------
    label_mask = label(mask2D);

    % -----------------------------
    % 🔵 Filtrage par taille
    % -----------------------------
    ms = measure(label_mask,[],'size');
    sizes = ms.size;

    % Seuil minimal réaliste pour un noyau
    min_allowed_size = pi * (rad^2) * 0.5;

    valid_ids = ms.ID(sizes > min_allowed_size);

    label_mask = label(ismember(double(label_mask), valid_ids));

else
    label_mask = mask;
end
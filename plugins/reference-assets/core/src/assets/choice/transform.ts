import type { TransformFunction } from '@player-ui/player';
import type { ChoiceAsset, TransformedChoice } from './types';
import { choicesEntryTransform } from './choices-entry'

/**
 * Choice asset transform
 */
export const choiceTransform: TransformFunction<ChoiceAsset, TransformedChoice> = (
  asset,
  options
) => {
  return {
    ...asset,
    set(val) {
      if (asset.binding === undefined) {
        return;
      }
      this.transformedChoices.forEach(entry => {
        if (entry.value === val) {
          entry.set(true);
        } else if (entry.selected) {
          entry.set(false);
        }
      });
      return options.data.model.set([[asset.binding, val]]);
    },
    validation:
      asset.binding === undefined
        ? undefined
        : options.validation?.get(asset.binding, { track: true }),
    transformedChoices: asset.choices.map(choicesEntryTransform)
  };
};
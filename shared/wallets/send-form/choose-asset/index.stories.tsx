import * as React from 'react'
import {action, storiesOf} from '../../../stories/storybook'
import ChooseAsset from '.'

const props = {
  displayChoices: [
    {currencyCode: 'Lumens', selected: false, symbol: 'XLM', type: 'display choice' as 'display choice'},
    {currencyCode: 'USD', selected: false, symbol: '$', type: 'display choice' as 'display choice'},
    {currencyCode: 'EUR', selected: true, symbol: '€', type: 'display choice' as 'display choice'},
    {currencyCode: 'GBP', selected: false, symbol: '£', type: 'display choice' as 'display choice'},
    {currencyCode: 'CAD', selected: false, symbol: '$', type: 'display choice' as 'display choice'},
    {currencyCode: 'CRC', selected: false, symbol: '₡', type: 'display choice' as 'display choice'},
    {currencyCode: 'JPY', selected: false, symbol: '¥', type: 'display choice' as 'display choice'},
    {currencyCode: 'FJD', selected: false, symbol: '$', type: 'display choice' as 'display choice'},
    {currencyCode: 'HNL', selected: false, symbol: 'L', type: 'display choice' as 'display choice'},
    {currencyCode: 'KRW', selected: false, symbol: '₩', type: 'display choice' as 'display choice'},
  ],
  isRequest: false,
  onBack: action('onBack'),
  onChoose: action('onChoose'),
  onRefresh: action('onRefresh'),
  otherChoices: [
    {
      currencyCode: 'BTC',
      disabledExplanation: '',
      issuer: 'Stronghold.co',
      selected: false,
      type: 'other choice' as 'other choice',
    },
    {
      currencyCode: 'KEYZ',
      disabledExplanation: '',
      issuer: 'Unknown',
      selected: false,
      type: 'other choice' as 'other choice',
    },
    {
      currencyCode: 'HUGZ',
      disabledExplanation: `max doesn't accept HUGZ.`,
      issuer: 'Jed',
      selected: false,
      type: 'other choice' as 'other choice',
    },
  ],
  selected: 'XLM',
}

const load = () => {
  storiesOf('Wallets/SendForm', module).add('Choose asset', () => <ChooseAsset {...props} />)
}

export default load

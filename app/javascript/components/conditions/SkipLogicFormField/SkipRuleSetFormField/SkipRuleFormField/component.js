import React from 'react';
import PropTypes from 'prop-types';
import { inject, observer, Provider } from 'mobx-react';

import { provideConditionSetStore } from '../../../ConditionSetFormField/utils';
import ConditionSetFormField from '../../../ConditionSetFormField/component';
import FormSelect from '../../../FormSelect/component';

@inject('conditionSetStore')
@observer
class SkipRuleFormFieldRoot extends React.Component {
  static propTypes = {
    conditionSetStore: PropTypes.object.isRequired,
    destItemId: PropTypes.string,
    destination: PropTypes.string.isRequired,
    hide: PropTypes.bool.isRequired,
    namePrefix: PropTypes.string.isRequired,
    ruleId: PropTypes.string.isRequired,

    // TODO: Describe these prop types.
    /* eslint-disable react/forbid-prop-types */
    remove: PropTypes.any,
    id: PropTypes.any,
    laterItems: PropTypes.any,
    skipIf: PropTypes.any,
    conditions: PropTypes.any,
    refableQings: PropTypes.any,
    formId: PropTypes.any,
    /* eslint-enable */
  };

  constructor(props) {
    super(props);

    const {
      conditionSetStore,
      namePrefix,
      remove,
      id,
      skipIf,
      conditions,
      refableQings,
      formId,
      destination,
      destItemId,
    } = this.props;
    const destItemIdOrEnd = destination === 'end' ? 'end' : destItemId;

    this.state = {
      remove,
      skipIf,
      destItemIdOrEnd,
      destination,
      destItemId,
    };

    conditionSetStore.initialize({
      formId,
      namePrefix: `${namePrefix}[conditions_attributes]`,
      conditions,
      conditionableId: id,
      conditionableType: 'SkipRule',
      refableQings,
      hide: skipIf === 'always',
    });
  }

  destinationOptionChanged = (value) => {
    this.setState({
      destItemIdOrEnd: value,
      destination: value === 'end' ? 'end' : 'item',
      destItemId: value === 'end' ? null : value,
    });
  }

  skipIfChanged = (event) => {
    const { conditionSetStore } = this.props;
    const skipIf = event.target.value;
    this.setState({ skipIf });
    conditionSetStore.hide = skipIf === 'always';
  }

  handleRemoveClick = () => {
    this.setState({ remove: true });
  }

  formatTargetItemOptions = (items) => {
    return items.map((o) => {
      return {
        id: o.id,
        key: o.id,
        name: I18n.t('skip_rule.skip_to_item', { label: `${o.fullDottedRank}. ${o.code}` }),
      };
    }).concat([{ id: 'end', name: I18n.t('form_item.skip_logic_options.end_of_form'), key: 'end' }]);
  }

  skipIfOptionTags = () => {
    const skipIfOptions = ['always', 'all_met', 'any_met'];
    return skipIfOptions.map((option) => (
      <option
        key={option}
        value={option}
      >
        {I18n.t(`skip_rule.skip_if_options.${option}`)}
      </option>
    ));
  }

  shouldDestroy = () => {
    const { hide } = this.props;
    const { remove } = this.state;
    return remove || hide;
  }

  render() {
    const { id, laterItems, namePrefix, ruleId } = this.props;
    const { destItemIdOrEnd, skipIf, destination, destItemId } = this.state;
    const idFieldProps = {
      type: 'hidden',
      name: `${namePrefix}[id]`,
      value: id || '',
    };
    const destinationProps = {
      name: `${namePrefix}[destination]`,
      value: destItemIdOrEnd || '',
      prompt: I18n.t('skip_rule.dest_prompt'),
      options: this.formatTargetItemOptions(laterItems),
      onChange: this.destinationOptionChanged,
    };
    const skipIfProps = {
      name: `${namePrefix}[skip_if]`,
      value: skipIf,
      className: 'form-control',
      onChange: this.skipIfChanged,
    };
    const destroyFieldProps = {
      type: 'hidden',
      name: `${namePrefix}[_destroy]`,
      value: this.shouldDestroy() ? '1' : '0',
    };

    return (
      <div
        className="skip-rule"
        style={{ display: this.shouldDestroy() ? 'none' : '' }}
      >
        <div className="skip-rule-main">
          <div className="skip-rule-attribs">
            <FormSelect {...destinationProps} />
            <select {...skipIfProps}>
              {this.skipIfOptionTags()}
            </select>
            <div className={`skip-rule-remove ${ruleId}`}>
              {/* TODO: Improve a11y. */}
              {/* eslint-disable-next-line */}
              <a onClick={this.handleRemoveClick}>
                <i className="fa fa-close" />
              </a>
            </div>
          </div>
          <ConditionSetFormField />
          <input {...idFieldProps} />
          <input {...destroyFieldProps} />
          <input
            name={`${namePrefix}[destination]`}
            type="hidden"
            value={destination}
          />
          <input
            name={`${namePrefix}[dest_item_id]`}
            type="hidden"
            value={destItemId || ''}
          />
        </div>
      </div>
    );
  }
}

const SkipRuleFormField = (props) => (
  // eslint-disable-next-line react/prop-types, react/destructuring-assignment
  <Provider conditionSetStore={provideConditionSetStore(`skip-${props.ruleId}`)}>
    <SkipRuleFormFieldRoot {...props} />
  </Provider>
);

export default SkipRuleFormField;

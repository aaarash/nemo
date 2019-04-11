import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'mobx-react';

import SkipRuleSetFormField from './SkipRuleSetFormField';
import { createConditionSetStore } from './ConditionSetModel/utils';

class SkipLogicFormFieldRoot extends React.Component {
  static propTypes = {
    type: PropTypes.string.isRequired,
    skipRules: PropTypes.arrayOf(PropTypes.object).isRequired,
  };

  constructor(props) {
    super(props);
    const { type, skipRules } = this.props;
    const skip = skipRules.length === 0 ? 'dont_skip' : 'skip';
    this.state = { type, skip };
  }

  skipOptionChanged = (event) => {
    this.setState({ skip: event.target.value });
  }

  skipOptionTags = () => {
    const skipOptions = ['dont_skip', 'skip'];
    return skipOptions.map((option) => (
      <option
        key={option}
        value={option}
      >
        {I18n.t(`form_item.skip_logic_options.${option}`)}
      </option>
    ));
  }

  render() {
    const { skip, type } = this.state;
    const selectProps = {
      className: 'form-control skip-or-not',
      value: skip,
      onChange: this.skipOptionChanged,
      name: `${type}[skip_if]`,
      id: `${type}_skip_logic`,
    };

    return (
      <div className="skip-logic-container">
        <select {...selectProps}>
          {this.skipOptionTags()}
        </select>
        <SkipRuleSetFormField
          hide={skip === 'dont_skip'}
          {...this.props}
        />
      </div>
    );
  }
}

const SkipLogicFormField = (props) => (
  <Provider conditionSetStore={createConditionSetStore('skipLogic')}>
    <SkipLogicFormFieldRoot {...props} />
  </Provider>
);

export default SkipLogicFormField;

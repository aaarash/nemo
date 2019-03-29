import React from 'react';
import PropTypes from 'prop-types';

import CascadingSelect from './CascadingSelect';

class ConditionValueField extends React.Component {
  render() {
    const { type, value, id, name } = this.props;
    if (type === 'cascading_select') {
      return <CascadingSelect {...this.props} />;
    }
    return (
      <input
        className="text form-control"
        defaultValue={value}
        id={id}
        key="input"
        name={name}
        type="text"
      />
    );
  }
}

ConditionValueField.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string,
  type: PropTypes.string.isRequired,
  value: PropTypes.string,
};

// These are not needed for CascadingSelect
ConditionValueField.defaultProps = {
  name: null,
  value: null,
};

export default ConditionValueField;

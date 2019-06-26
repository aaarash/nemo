import React from 'react';
import PropTypes from 'prop-types';
import { inject, observer } from 'mobx-react';
import Form from 'react-bootstrap/Form';

import ConditionSetFormField from '../../../ConditionSetFormField/component';
import AddConditionLink from '../../../AddConditionLink/component';

@inject('conditionSetStore')
@observer
class ConstraintFormField extends React.Component {
  static propTypes = {
    conditionSetStore: PropTypes.object.isRequired,
    id: PropTypes.string,
    constraintId: PropTypes.string.isRequired,
    acceptIf: PropTypes.string.isRequired,
    hide: PropTypes.bool,
    namePrefix: PropTypes.string.isRequired,
    remove: PropTypes.bool,
  };

  static defaultProps = {
    remove: false,
    hide: false,
  };

  constructor(props) {
    super(props);

    const {
      remove,
      acceptIf,
    } = this.props;

    this.state = {
      remove,
      acceptIf,
    };
  }

  handleAcceptIfChange = (event) => {
    const acceptIf = event.target.value;
    this.setState({ acceptIf });
  }

  handleRemoveClick = () => {
    this.setState({ remove: true });
  }

  shouldDestroy = () => {
    const { hide } = this.props;
    const { remove } = this.state;
    return remove || hide;
  }

  render() {
    const { id, namePrefix, constraintId, conditionSetStore: { conditionCount } } = this.props;
    const { acceptIf } = this.state;

    return (
      <div
        className="rule"
        style={{ display: this.shouldDestroy() ? 'none' : '' }}
      >
        <div className={`rule-main rule-${constraintId}`}>
          <ConditionSetFormField />
          { conditionCount > 1 && (
            <div key="accept-if">
              {['all_met', 'any_met'].map((key) => (
                <Form.Check
                  inline
                  checked={acceptIf === key}
                  onChange={this.handleAcceptIfChange}
                  label={I18n.t(`form_item.accept_if_options.${key}`)}
                  type="radio"
                  value={key}
                  key={key}
                  name={`${namePrefix}[accept_if]`}
                />
              ))}
            </div>
          )}
          <div className="links">
            <AddConditionLink />
            &nbsp;&nbsp;
            {/* TODO: Improve a11y. */}
            {/* eslint-disable-next-line */}
            <a onClick={this.handleRemoveClick} tabIndex="0">
              <i className="fa fa-trash" />
              {' '}
              {I18n.t('form_item.delete_rule')}
            </a>
          </div>
          <input
            type="hidden"
            name={`${namePrefix}[id]`}
            value={id || ''}
          />
          <input
            type="hidden"
            name={`${namePrefix}[_destroy]`}
            value={this.shouldDestroy() ? '1' : '0'}
          />
        </div>
      </div>
    );
  }
}

export default ConstraintFormField;

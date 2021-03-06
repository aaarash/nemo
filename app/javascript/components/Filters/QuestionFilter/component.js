import React from 'react';
import PropTypes from 'prop-types';
import { inject, observer } from 'mobx-react';

import { getItemNameFromId } from '../utils';
import ConditionSetFormField from '../../conditions/ConditionSetFormField/component';
import FilterOverlayTrigger from '../FilterOverlayTrigger/component';

@inject('filtersStore')
@observer
class QuestionFilter extends React.Component {
  static propTypes = {
    filtersStore: PropTypes.object,
    onSubmit: PropTypes.func.isRequired,
  };

  async componentDidMount() {
    const { filtersStore } = this.props;
    await filtersStore.updateRefableQings();
  }

  renderPopover = () => {
    return (
      <ConditionSetFormField />
    );
  }

  render() {
    const { filtersStore: { conditionSetStore }, onSubmit } = this.props;
    const { original: { conditions }, refableQings } = conditionSetStore;
    const hints = conditions
      .filter(({ leftQingId }) => leftQingId)
      .map(({ leftQingId }) => getItemNameFromId(refableQings, leftQingId, 'code'));

    return (
      <FilterOverlayTrigger
        id="question-filter"
        title={I18n.t('filter.question')}
        popoverContent={this.renderPopover()}
        popoverClass="wide display-logic-container"
        buttonsContainerClass="condition-margin"
        onSubmit={onSubmit}
        hints={hints}
        buttonClass="btn-margin-left"
      />
    );
  }
}

export default QuestionFilter;

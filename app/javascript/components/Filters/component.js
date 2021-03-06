import React from 'react';
import PropTypes from 'prop-types';
import ButtonToolbar from 'react-bootstrap/ButtonToolbar';
import { observer, inject } from 'mobx-react';

import { CONTROLLER_NAME, getFilterString, submitSearch } from './utils';
import FormFilter from './FormFilter/component';
import QuestionFilter from './QuestionFilter/component';
import ReviewedFilter from './ReviewedFilter/component';
import SubmitterFilter from './SubmitterFilter/component';
import AdvancedSearchFilter from './AdvancedSearchFilter/component';

@inject('filtersStore')
@inject('conditionSetStore')
@observer
class Filters extends React.Component {
  static propTypes = {
    filtersStore: PropTypes.object.isRequired,
    conditionSetStore: PropTypes.object.isRequired,
    controllerName: PropTypes.string,
  };

  static defaultProps = {
    // This is expected to be null if the feature flag is disabled.
    controllerName: null,
  };

  handleSubmit = () => {
    const { filtersStore } = this.props;
    const filterString = getFilterString(filtersStore);
    submitSearch(filterString);
  }

  handleClearFilters = () => {
    submitSearch(null);
  }

  renderFilterButtons = () => {
    const defaultProps = {
      onSubmit: this.handleSubmit,
    };

    return (
      <ButtonToolbar>
        <FormFilter {...defaultProps} />
        <QuestionFilter {...defaultProps} />
        <ReviewedFilter {...defaultProps} />
        <SubmitterFilter {...defaultProps} />
      </ButtonToolbar>
    );
  }

  render() {
    const { controllerName } = this.props;
    const shouldRenderButtons = controllerName === CONTROLLER_NAME.RESPONSES;

    return (
      <div className="filters">
        {shouldRenderButtons ? this.renderFilterButtons() : null}

        <AdvancedSearchFilter
          onClear={this.handleClearFilters}
          onSubmit={this.handleSubmit}
        />
      </div>
    );
  }
}

export default Filters;

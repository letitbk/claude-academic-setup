---
name: qualtrics-survey
description: Manage Qualtrics surveys via API - list blocks/questions, create/update questions, add JavaScript, manage embedded data and display logic. Use for modifying existing surveys with LLM-powered features.
---

# Qualtrics Survey Management

A skill for programmatically managing Qualtrics surveys through the API. Supports reading survey structure, creating/updating questions, managing blocks, adding JavaScript, and configuring display logic.

## Setup

### Required Environment Variables
```bash
# In ~/.zshrc
export QUALTRICS_API_KEY='your-api-key'
export QUALTRICS_BASE_URL='nyu.qualtrics.com'  # Your datacenter
```

### Survey ID
The skill reads the survey ID from the project's `CLAUDE.md` file. Look for:
```
**Survey ID**: `SV_xxxxxxxx`
```

## Shortcut Commands

### list-blocks
List all blocks with their questions:
```
/qualtrics-survey list-blocks
```

### list-questions
List all questions with IDs, types, and block assignments:
```
/qualtrics-survey list-questions
```

### add-question
Interactive wizard to create a new question:
```
/qualtrics-survey add-question
```

### update-js
Update a question's JavaScript from the project's js/ folder:
```
/qualtrics-survey update-js QID58 task_generator.js
```

## API Patterns

### Get Survey Structure
```bash
# Get full survey definition
curl -s -X GET "https://${QUALTRICS_BASE_URL}/API/v3/survey-definitions/${SURVEY_ID}" \
  -H "X-API-TOKEN: ${QUALTRICS_API_KEY}" \
  -H "Content-Type: application/json"

# Get specific question
curl -s -X GET "https://${QUALTRICS_BASE_URL}/API/v3/survey-definitions/${SURVEY_ID}/questions/${QID}" \
  -H "X-API-TOKEN: ${QUALTRICS_API_KEY}"

# Get survey flow
curl -s -X GET "https://${QUALTRICS_BASE_URL}/API/v3/survey-definitions/${SURVEY_ID}/flow" \
  -H "X-API-TOKEN: ${QUALTRICS_API_KEY}"
```

### Create Questions

#### Multiple Choice (Single Answer)
```python
payload = {
    "QuestionText": "Your question text here",
    "QuestionType": "MC",
    "Selector": "SAVR",  # Single answer vertical radio
    "SubSelector": "TX",
    "DataExportTag": "Q1_Tag",
    "Choices": {
        "1": {"Display": "Option 1"},
        "2": {"Display": "Option 2"},
        "3": {"Display": "Option 3"}
    },
    "ChoiceOrder": [1, 2, 3],
    "Validation": {"Settings": {"ForceResponse": "ON", "Type": "None"}},
    "Language": []
}
# POST to /API/v3/survey-definitions/{surveyId}/questions?blockId={blockId}
```

#### Multiple Choice (Multi-Select)
```python
payload = {
    "QuestionType": "MC",
    "Selector": "MAVR",  # Multiple answer vertical
    # ... same structure as above
}
```

#### Matrix/Likert
```python
payload = {
    "QuestionText": "Rate the following:",
    "QuestionType": "Matrix",
    "Selector": "Likert",
    "SubSelector": "SingleAnswer",
    "DataExportTag": "Matrix1",
    "Choices": {  # Rows
        "1": {"Display": "Item 1"},
        "2": {"Display": "Item 2"}
    },
    "ChoiceOrder": [1, 2],
    "Answers": {  # Columns
        "1": {"Display": "Strongly Disagree"},
        "2": {"Display": "Disagree"},
        "3": {"Display": "Neutral"},
        "4": {"Display": "Agree"},
        "5": {"Display": "Strongly Agree"}
    },
    "AnswerOrder": [1, 2, 3, 4, 5]
}
```

#### Text Entry
```python
payload = {
    "QuestionText": "Please describe:",
    "QuestionType": "TE",
    "Selector": "ML",  # Multi-line, or "SL" for single-line
    "DataExportTag": "OpenText1",  # REQUIRED for TE questions
    "Validation": {"Settings": {"ForceResponse": "OFF", "Type": "None"}}
}
```

### Update Questions

```python
# PUT to /API/v3/survey-definitions/{surveyId}/questions/{questionId}
# Must include ALL required fields (QuestionText, QuestionType, Selector, etc.)
payload = {
    "QuestionText": "Updated text",
    "QuestionType": "MC",
    "Selector": "SAVR",
    "Choices": {...},
    "ChoiceOrder": [...],
    "QuestionJS": "Qualtrics.SurveyEngine.addOnload(function() { ... });"
}
```

### Manage Blocks

#### Reorder Questions in Block
```python
payload = {
    "Type": "Standard",
    "Description": "Block Name",
    "BlockElements": [
        {"Type": "Question", "QuestionID": "QID1"},
        {"Type": "Question", "QuestionID": "QID2"},
        {"Type": "Question", "QuestionID": "QID3"}
    ]
}
# PUT to /API/v3/survey-definitions/{surveyId}/blocks/{blockId}
```

### Display Logic

```python
"DisplayLogic": {
    "0": {
        "0": {
            "LogicType": "Question",
            "QuestionID": "QID45",
            "QuestionIsInLoop": "no",
            "ChoiceLocator": "q://QID45/SelectableChoice/1",
            "Operator": "Selected",
            "QuestionIDFromLocator": "QID45",
            "LeftOperand": "q://QID45/SelectableChoice/1",
            "Type": "Expression",
            "Description": "If QID45 Choice 1 Is Selected"
        },
        "Type": "If"
    },
    "Type": "BooleanExpression",
    "inPage": False
}
```

### Embedded Data in Survey Flow

**IMPORTANT**: Use `Type: "Custom"` to preserve default values. `Type: "Recipient"` strips the Value property.

```python
{
    "Type": "EmbeddedData",
    "FlowID": "FL_1",
    "EmbeddedData": [
        {"Description": "field_name", "Type": "Custom", "Field": "field_name", "VariableType": "String", "Value": "default_value"},
        {"Description": "another_field", "Type": "Custom", "Field": "another_field", "VariableType": "String", "Value": ""}
    ]
}
```

## JavaScript Patterns

### Update Matrix Row Labels from Embedded Data
```javascript
Qualtrics.SurveyEngine.addOnload(function() {
    var that = this;
    var blockItems = Qualtrics.SurveyEngine.getEmbeddedData('block_A');
    if (!blockItems) return;

    var itemNumbers = blockItems.split(',').map(function(x) { return parseInt(x.trim(), 10); });
    var itemTexts = [];

    for (var i = 0; i < itemNumbers.length; i++) {
        var text = Qualtrics.SurveyEngine.getEmbeddedData('rel_item_' + itemNumbers[i]);
        itemTexts.push(text || 'Item not found');
    }

    setTimeout(function() {
        var container = that.getQuestionContainer();
        var choiceRows = container.querySelectorAll('.ChoiceRow');
        choiceRows.forEach(function(row, idx) {
            if (idx < itemTexts.length) {
                var label = row.querySelector('.LabelWrapper');
                if (label) label.textContent = itemTexts[idx];
            }
        });
    }, 200);
});
```

### Capture Checkbox Selections on Page Submit
```javascript
Qualtrics.SurveyEngine.addOnPageSubmit(function() {
    var questionContainer = this.getQuestionContainer();
    var selectedCheckboxes = questionContainer.querySelectorAll('input[type="checkbox"]:checked');
    var selectedItems = [];

    selectedCheckboxes.forEach(function(checkbox) {
        var choiceDiv = checkbox.closest('.Choice');
        if (choiceDiv) {
            var labelWrapper = choiceDiv.querySelector('.LabelWrapper');
            if (labelWrapper) {
                selectedItems.push(labelWrapper.textContent.trim());
            }
        }
    });

    Qualtrics.SurveyEngine.setEmbeddedData('selected_items', JSON.stringify(selectedItems));
});
```

### LLM API Call via Proxy
```javascript
Qualtrics.SurveyEngine.addOnload(function() {
    var that = this;
    var proxyUrl = 'https://your-proxy.vercel.app/api/endpoint';
    var inputData = Qualtrics.SurveyEngine.getEmbeddedData('input_field');

    jQuery("#NextButton").hide();

    var timeoutId = setTimeout(function() { handleError('Timeout'); }, 30000);

    fetch(proxyUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: inputData })
    })
    .then(function(response) {
        clearTimeout(timeoutId);
        if (!response.ok) throw new Error('Server error');
        return response.json();
    })
    .then(function(data) {
        Qualtrics.SurveyEngine.setEmbeddedData('result', JSON.stringify(data));
        // Update UI...
        jQuery("#NextButton").show();
    })
    .catch(function(error) {
        clearTimeout(timeoutId);
        handleError(error.message);
    });

    function handleError(msg) {
        Qualtrics.SurveyEngine.setEmbeddedData('api_error', msg);
        // Fallback logic...
        jQuery("#NextButton").show();
    }
});
```

## Workflow

1. **Read CLAUDE.md** to get survey ID and current structure
2. **Ask user** which operation to perform
3. **Fetch current state** from API (no caching)
4. **Show preview** of proposed changes
5. **Confirm** before executing
6. **Execute** API calls
7. **Verify** changes were applied

## Common Tasks

### Add LLM-Powered Question
1. Create text entry question for user input
2. Create confirmation question (MC) for LLM response
3. Add JavaScript to confirmation question (from js/ folder)
4. Add embedded data fields to survey flow
5. Configure display logic if needed

### Split Matrix into Randomized Blocks
1. Create N matrix questions (one per block)
2. Add randomization JS to first survey page
3. Add embedded data fields for block assignments
4. Add row-update JS to each matrix question

### Add Conditional Follow-up
1. Create primary question (MC)
2. Create follow-up questions (one per response option)
3. Add display logic to each follow-up
4. Test skip patterns

## Tips

- Always include all required fields when updating questions
- Use `DataExportTag` for text entry questions (required)
- `Type: "Custom"` for embedded data with default values
- Use `setTimeout(fn, 200)` for DOM manipulation after page load
- Test JavaScript in browser console before adding to question
- Check survey preview after each change

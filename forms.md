You are an amazing software architect and developer. You are able to create the most complex and advanced software solutions with ease.
You love clean code, clean structures, good architecture, great user and developer experience, great documentation, you have repition and duplications in code and you love to remove them and replace them with better solutions.

We are currently building our awesome flutter obers_ui kit. I have attached our AI information document, that contains all of the available elements and our general api structure.

The idea is to have one fully universal Flutter toolkit, that allows us to create even the most complicated projects, platforms and applications with ease. 

To make this possible now, we want to extend our uikit with a stateful form solution, that makes handling form data a breeze.
The important thing about this is though, that this stateful form handling is fully optin and all avialable input widgets should still work without it.

Your job now is to take the following requirements and ideas and design a clean, nicely structured and easy to use form solution that fits perfectly into our obers_ui kit and is "the flutter way" to do it.

Please analyze the requirements and ideas and design a clean, nicely structured and easy to use form solution by defining how it works over all, how it is structured and how it is implemented.

THink about the general structure, the best way to implement it and the best way to structure the code.
Then also think about potential edge cases and how to handle them.
Then also think about potential improvements and how to make it even better.
Then also think about potential future features and how to implement them.
Then also think about potential performance optimizations and how to make it even faster.
Then also think about potential accessibility features and how to make it even more accessible.
Then also think about potential internationalization features and how to make it even more international.
Then also think about how I want to make it and think if there is an even better way, that still maintains type safety, ease of use for the developer and great user experience and the following requirements.
Think about internationalization, accessibility, performance, testing, documentation, etc.'
Think about all test case scenarios and edge cases and how to handle them.

# Requirements

* Fully optional to use
* Very high focus on developer experience, that need to implement this
* Fully documented in AI File and our docs
* Fully tested
* 100% fully type safe (no Map<String, dynamic> except for the jsonExport or maybe for saving temporary data/state, that is never anywhere outside of the class and only if no other way)
* Clean Code, clean structures, no code reuse
* Amazing declarative api, that is easy to read and guess. (see our current conventions and system of naming and structure)
* available as a separate dart package developed under ./packages/obers_ui_forms
* Able to handle all kinds of input data
* Easy access to data from within the form, but also outside (through FormController)
* Great flexibility with validation
* Fully implemented state management by default, when wrapping the form with the OiForm widget (context based communication with inputs)
* All data related things are defined in FormController, all visual details are defined with the InputWidget
* Simple configuration and good defaults
* Needs to support all kinds of input widgets, that are available in the core obers_ui package
* Needs to support user experience features like enter to submit on fields (except for multiline text fields or other fields that are not meant to be submitted), tab index, focus, blur, validation, error messages, etc.
* Minimal boilerplate and overhead if possible
* Needs to collect error messages and display them in a way, that is easy to read and understand
* Needs to show error messages right next to the input field, that is causing the error and additionally a global error message at the top of the form
* Good performance
* The api and structure should follow the same patterns and structure as the rest of the obers_ui kit and the ai information document.
* The api and structure should be easy to understand and use for the developer.
* The api and structure should be easy to extend and customize.
* The api and structure should be easy to test.
* The api and structure should be easy to document.
* The api and structure should be easy to internationalize.
* The api and structure should be easy to performance optimize.
* The api and structure should be easy to accessibility optimize.

# Structure

To make sure we can hit all requirements I propose the following architecture seen in the example below:


```dart
// signup_form_controller.dart
...

// to make sure everything stays typesafe, we define all columns as enum values
enum SignupFormInputs {
    name,
    email,
    password,
    passwordRepeat,
    acceptTerms,
    source,
    gender,
}

// every form controllers extends or implements a mixin (whatever is better for our usecase) that contains structure and shared methods and functionality, that we will use
class SignupFormController extends OiFormController {
    // here are the actual data entries I want to save
    final String name;
    final String username;
    final String email;
    final String password;
    final String passwordRepeat;
    final bool? newsletterSignup;
    final String source;
    final String gender;

    const SignupFormController(this.name, this.username, this.email, this.password, this.passwordRepeat, this.newsletterSignup, this.source, this.gender);

    // then we define some data relevant configurations
    inputs() {
        return {
            SignupFormInputs.name: OiFormInputController<String>(
                required: true,
                validation: [
                    OiFormValidation.min(5),
                    OiFormValidation.min(60),
                ]
            ),
            SignupFormInputs.email: OiFormInputController<String>(
                required: true,
                validation: [
                    OiFormValidation.email,
                ]
            ),
            SignupFormInputs.password: OiFormInputController<String>(
                // here we can define, whether a field is required. Default is false
                required: true,
                // here we can pass an array of potential validation rules, that are defines as separate class methods. We will have a few predefined ones like these here, but we could also make completely custom one, by just writing a method, that takes the value (will be dependency injected at the time automatically and does not need to be passed by the user, also the overall form data will be injected automatically to make sure we co do stuff like "equals", ... as well) and configuration options and just throws an Exception with the error message (if not working) that will be caught automatically in the logic wrapper and then added to the "error message" array and the field specific error message array or it returns true if it is valid
                validation: [
                    OiFormValidation.regex('/[\W\d\-\$]{4,}/'),
                    OiFormValidation.securePassword(min: 5, requiresUppercase: true, requiresSpecialChar: true,),
                ]
            ),
            SignupFormInputs.passwordRepeat: OiFormInputController<String>(
                required: true,
                validation: [
                    OiFormValidation.equals(OiFormValidation.password),
                ],
                // with this option we can define, that the field is not saved to the form controller, but only used for validation and display purposes
                save: false,
            ),
            SignupFormInputs.newsletterSignup: OiFormInputController<bool>(
                required: false,
                // here we define transformers, that set and get the value on change to make sure we transform it correctly before and after changing and submit
                getter: bool (val) => val == true || val == 'true' ? true : false,
                setter: (val) => (string) val,
            ),
            SignupFormInputs.source: OiFormInputController<List<String>>(
                // this is an example of a dynamic search combobox that should allow multiple values, that are search on demand 
                optionQuery: (String input) => myApi.fetchSources(input),
                // if this is set to true, the options will be loaded from the start and not just when the user opens the combobox dropdown (default true)
                initFetch: true,
            ),
            SignupFormInputs.gender: OiFormInputController<String>(
                // this is an example of a static dropdown with only one value
                options: [
                    'male',
                    'female',
                ],
                required: true,
            ),
            // we walso want to be able to create "virtual" fields, that are generated from other fields
            SignupFormInputs.username: OiFormInputController<String>(
                required: true,
                // this is the field, that we want to watch and update the value of the virtual field from. If anything changes here, the value of the virtual field will be updated.
                watch: [SignupFormInputs.name],
                // this is the default and means, that the value will be updated when the watched field changes. Other options are: onInit, onSubmit, onDirty, onValid, onInvalid. 
                watchMode: OiFormWatchMode.onChange, 
                // This is also the place where we can define the value of the virtual field.
                value: (formController) => formController.name.toLowerCase().replaceAll(' ', '_'),
            ),
        };
    }
}
```

This is how it should be usabe:
```dart

class SignupForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final formController = SignupFormController(
        newsletterSignup: true,
    );

    // it should also be possible to overwrite the input controller for one specific field, so it can be used and controlled from outside of the form controller
    final nameInputController = OiFormInputController<String>(
        required: true,
        validation: [
            OiFormValidation.min(5),
            OiFormValidation.min(60),
        ]
    );

    formController.overwriteInputController(SignupFormInputs.name, nameInputController);

    // or even to get, change and then overwrite the input controller for one specific field
    final nameInputController = formController.getInputController(SignupFormInputs.name);
    nameInputController.required = true;
    nameInputController.validation = [
        OiFormValidation.min(5),
        OiFormValidation.min(60),
    ];
    formController.overwriteInputController(SignupFormInputs.name, nameInputController);

    return OiForm(
        onSubmit: (data, formController) => print(data, formController.isValid),
        controller: formController,
        sections: [
            // this OiFormElement is just a wrapper around the input widget, that is used to display the label, connects the input smartly to the form controller and displays the error message if there is one. This is also the place where we can define the type of the input widget and the key of the input widget.
            OiFormElement(label: 'Name'
                input:
                    OiTextInput(key: SignupFormInputs.name),
            ),
            OiFormElement(
                label: 'Email',
                input:
                    OiTextInput(key: SignupFormInputs.email, , type: OiFieldType.email),
            ),
            OiFormElement(
                label: 'Password',
                input:
                    OiTextInput(key: SignupFormInputs.password, type: OiFieldType.password),
            ),
            OiFormElement(
                label: 'Password Repeat'
                input:
                    OiFormField(key: SignupFormInputs.passwordRepeat, type: OiFieldType.password),
                // this tells the form controller, that if something changes we will reevaluate the validation of the password field
                revalidateOnChangeOf: [SignupFormInputs.password],
            ),
            OiFormElement(
                label: 'Newsletter Signup',
                input:
                    OiCheckbox(key: SignupFormInputs.newsletterSignup),
            ),
            OiFormElement(
                label: 'Source',
                input:
                    OiFormSelect(key: SignupFormInputs.source,  searchable: true, multiple: true, placeholder: 'Select Source'),
            ),
            OiFormElement(
                label: 'Gender',
                input:
                    OiFormSelect(key: SignupFormInputs.gender, type: OiFieldType.select,
                    ),
                // it should also allow to hide the field based on a condition, that is defined in the form controller
                hideIf: (formController) => formController.newsletterSignup == false,
                // it should also allow to show the field based on a condition, that is defined in the form controller
                showIf: (formController) => formController.newsletterSignup == true,
            ),

            // there should also be an auto submit button, that is disabled if the form is not valid
            OiFormSubmitButton(
                onSubmit: () => formController.submit(),
                label: 'Submit',
                icon: Icons.send,
                style: OiButtonStyle.primary,
            ),

            // we also want to be able to reset the form
            OiButton(
                label: 'Reset',
                onTap: () => formController.reset(),
                style: OiButtonStyle.secondary,
            ),

            // we also want to be able to get the form data as a map of the form controller
            OiButton(
                label: 'Get Form Data',
                onTap: () => formController.getData(),
            ),

            // we also want to be able to validate the form
            OiButton(
                label: 'Validate Form',
                onTap: () => formController.validate(),
            ),

            // we also want to be able to submit the form
            OiButton(
                label: 'Submit Form',
                onTap: () => formController.submit(),
            ),

            // we also want to only read one specific field from the form controller
            OiButton(
                label: 'Get Name',
                onTap: () => formController.get<String>(SignupFormInputs.name),
            ),

            // we also want to only read one specific field from the form controller with a fallback value
            OiButton(
                label: 'Get Name with Fallback',
                onTap: () => formController.get<String>(SignupFormInputs.name, fallback: 'John Doe'),
            ),

            // we also want to be able to set one specific field in the form controller
            OiButton(
                label: 'Set Name',
                onTap: () => formController.set<String>(SignupFormInputs.name, 'John Doe'),
            ),

            // we also want to be able to set multiple fields in the form controller
            OiButton(
                label: 'Set Multiple Fields',
                onTap: () => formController.setMultiple([
                    SignupFormInputs.name: 'John Doe',
                    SignupFormInputs.email: 'john.doe@example.com',
                ]),
            ),

            // we also want to be able to get the error for one specific field from the form controller
            OiButton(
                label: 'Get Error',
                onTap: () => formController.getError(SignupFormInputs.name),
            ),

            // we also want to be able to set the error for one specific field in the form controller
            OiButton(
                label: 'Set Error',
                onTap: () => formController.setError(SignupFormInputs.name, 'Error'),
            ),

            // we also want to be able to get all errors from the form controller   
            OiButton(label: 'Get All Errors', onTap: () => formController.getErrors()),

            // we also want to be able to check if the form is dirty
            OiButton(label: 'Is Dirty', onTap: () => formController.isDirty),

            // we also want to be able to check if the form is valid
            OiButton(label: 'Is Valid', onTap: () => formController.isValid),

            // we also want to be able to check if a single field is dirty
            OiButton(label: 'Is Field Dirty', onTap: () => formController.isFieldDirty<String>(SignupFormInputs.name)),

            // we also want to be able to check if a single field is valid
            OiButton(label: 'Is Field Valid', onTap: () => formController.isFieldValid<String>(SignupFormInputs.name)),

            // we also want to be able to get the initial form data as a map of the form controller
            OiButton(label: 'Get Initial Form Data', onTap: () => formController.getInitial()),

            // we also want to be able to get a json export of the form controller
            OiButton(label: 'Get Json Export', onTap: () => formController.json()),

            // we also want to be able to disable the form
            OiButton(label: 'Disable Form', onTap: () => formController.disable()),

            // we also want to be able to enable the form
            OiButton(label: 'Enable Form', onTap: () => formController.enable()),

            // we also want to be able to disable a single field
            OiButton(label: 'Disable Field', onTap: () => formController.disableField(SignupFormInputs.name)),

            // we also want to be able to enable a single field
            OiButton(label: 'Enable Field', onTap: () => formController.enableField(SignupFormInputs.name)),

        ]
    );
  }
}
```
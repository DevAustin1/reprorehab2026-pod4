% EXPLANATION:
% webread lets MATLAB retrieve data from a web service such as an API.
% table organizes the extracted data into rows and named columns.
% No additional packages are needed for this example.


url = 'https://clinicaltrials.gov/api/v2/studies';


options = weboptions( ...
    'Timeout', 30, ...
    'ContentType', 'json' ...
);


% EXPLANATION:
% weboptions configures the request:
%   - Timeout sets the response timeout to 30 seconds.
%   - ContentType tells MATLAB to interpret the response as JSON.
%
% webread sends the request and converts the JSON response into
% MATLAB data structures. It raises an error if the request fails.


data = webread(url, ...
    'query.cond', 'migraine', ...
    'filter.overallStatus', 'RECRUITING', ...
    'pageSize', 10, ...
    'format', 'json', ...
    options ...
);


% EXPLANATION:
% Query parameters are supplied as name-value pairs.
% This request asks for up to 10 recruiting studies related to migraine.


studies = getFieldOrDefault(data, 'studies', []);
nStudies = numel(studies);


% EXPLANATION:
% Retrieve the studies returned by the API.
% If the response does not contain a studies field, use an empty array.
% getFieldOrDefault is a helper function defined at the end of this script.


StudyID = strings(nStudies, 1);
Title = strings(nStudies, 1);
Status = strings(nStudies, 1);
Enrollment = NaN(nStudies, 1);

StudyID(:) = missing;
Title(:) = missing;
Status(:) = missing;


% EXPLANATION:
% Preallocate one entry per study for each output variable.
% Text variables start with missing string values.
% Enrollment starts with NaN, MATLAB's numeric missing-value marker.


for i = 1:nStudies

    % JSON arrays may be decoded as structure arrays or cell arrays,
    % depending on whether their records have matching fields.
    if iscell(studies)
        study = studies{i};
    else
        study = studies(i);
    end

    protocol = getFieldOrDefault( ...
        study, 'protocolSection', struct() ...
    );

    identification = getFieldOrDefault( ...
        protocol, 'identificationModule', struct() ...
    );

    statusModule = getFieldOrDefault( ...
        protocol, 'statusModule', struct() ...
    );

    design = getFieldOrDefault( ...
        protocol, 'designModule', struct() ...
    );

    enrollmentInfo = getFieldOrDefault( ...
        design, 'enrollmentInfo', struct() ...
    );

    StudyID(i) = string(getFieldOrDefault( ...
        identification, 'nctId', missing ...
    ));

    Title(i) = string(getFieldOrDefault( ...
        identification, 'briefTitle', missing ...
    ));

    Status(i) = string(getFieldOrDefault( ...
        statusModule, 'overallStatus', missing ...
    ));

    count = getFieldOrDefault( ...
        enrollmentInfo, 'count', NaN ...
    );

    Enrollment(i) = str2double(string(count));

end


% EXPLANATION:
% The loop processes each study returned by the API.
%
% Study information is nested, so we first access protocolSection,
% then the modules containing identification, status, and design data.
%
% getFieldOrDefault returns a fallback value when a field is absent
% or empty, rather than stopping the script with an error.
%
% str2double converts enrollment values into numbers.
% Values that cannot be interpreted as numbers become NaN.


trials = table(StudyID, Title, Status, Enrollment);


% EXPLANATION:
% For a MATLAB table, each study becomes a row, and each input variable becomes a column.
% The input variable names become the table's column names.
% This also preserves the four columns if no studies were returned.
%
% Enrollment uses MATLAB's double numeric type so it can contain
% both whole-number counts and missing values represented by NaN.


disp(trials); %[output:0ccbffe4]


% EXPLANATION:
% Display the table in the Command Window.


writetable(trials, 'clinical_trials_matlab.csv', ...
    'WriteRowNames', false ...
);


% EXPLANATION:
% Save the table as a CSV file in the current working folder.
% Column names are included, but row names are not.
% The file can then be opened in Excel, MATLAB, or Python.


% LOCAL HELPER FUNCTION
% Keep this function at the end of the script.

function value = getFieldOrDefault(s, fieldName, defaultValue)

    if isstruct(s) && isscalar(s) && isfield(s, fieldName)
        value = s.(fieldName);

        if isempty(value)
            value = defaultValue;
        end
    else
        value = defaultValue;
    end

end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:0ccbffe4]
%   data: {"dataType":"text","outputData":{"text":"       <strong>StudyID<\/strong>                                                                                    <strong>Title<\/strong>                                                                                    <strong>Status<\/strong>       <strong>Enrollment<\/strong>\n    <strong>_____________<\/strong>    <strong>_______________________________________________________________________________________________________________________________________________________________<\/strong>    <strong>____________<\/strong>    <strong>__________<\/strong>\n\n    \"NCT06016465\"    \"Does Nerve Block + Oral Dexamethasone Reduce Recurrence of Headache Within 72 Hrs?\"                                                                               \"RECRUITING\"         84   \n    \"NCT07626307\"    \"Evaluation of the Performance of the Doraldo-Castelletti Scale in Supporting the Neurologist's Decision to Refer Migraine Patients to Physiotherapy\"              \"RECRUITING\"        439   \n    \"NCT03972124\"    \"Cannabis for the Prophylactic Treatment of Migraine\"                                                                                                              \"RECRUITING\"         72   \n    \"NCT04686253\"    \"Internal Microstructure of Patent Foramen Ovale Related to Stroke\"                                                                                                \"RECRUITING\"       1200   \n    \"NCT07871097\"    \"Acute Treatment of Vestibular Migraine by Rimegepant\"                                                                                                             \"RECRUITING\"         80   \n    \"NCT06473597\"    \"A Comparison of Nurtec ODT to Maxalt MLT-ODT in Adult ED Patients With Migraine Headache\"                                                                         \"RECRUITING\"         80   \n    \"NCT07072910\"    \"Cabergoline for Episodic Migraine\"                                                                                                                                \"RECRUITING\"        150   \n    \"NCT07645924\"    \"A Study to Evaluate the Efficacy and Safety of Elismetrep (K-304) in the Acute Treatment of Migraine\"                                                             \"RECRUITING\"       1800   \n    \"NCT07769255\"    \"Effect of Nebulized Dexmedetomidine on Central Sensitization and Chronification in Migraine\"                                                                      \"RECRUITING\"        146   \n    \"NCT06603558\"    \"Post-Marketing Study to Assess the Safety and Effectiveness of Oral Atogepant in Korean Adult Participants for the Prevention of Chronic or Episodic Migraine\"    \"RECRUITING\"       3000   \n\n","truncated":false}}
%---

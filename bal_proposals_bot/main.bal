import ballerina/io;
import ballerina/lang.runtime;
import ballerina/http;

type Data record {
    int total_count;
    Issue[] items;
};

type Issue record {
    string html_url;
    string title;
};

// string[] repoList = [
//     "ballerina-lang",
//     "ballerina-standard-library",
//     "plugin-vscode-compiler-toolkit",
//     "nballerina",
//     "ballerina-dev-tools",
//     "ballerina-performance-cloud",
//     "module-ballerina-docker",
//     "module-ballerina-c2c",
//     "module-ballerinax-aws.lambda",
//     "module-ballerinax-azure.functions",
//     "openapi-tools",
//     "ballerina-update-tool",
//     "ballerina-distribution",
//     "ballerina-spec"
// ];
string[] repoList = [
    "ballerina-lang",
    "ballerina-standard-library"
];

public function main() returns error? {
    //io:println("Hello, World!");

    string repoData = "";

    int repoCount = 0;
    foreach string repository in repoList {
        repoCount = repoCount + 1;
        if (repoCount % 9 == 0) {
            io:println("Sleeping:", repoCount);
            runtime:sleep(65);
        }
        http:Client github = check new ("https://api.github.com/search/issues");
        Data data = check github->get(string `?q=label:Type/Proposal+repo:ballerina-platform/${repository}+is:open`);
        int issueCount = data.total_count;
        if (issueCount > 0) {
            string issuelist = "";
            foreach var issue in data.items {
                issuelist = issuelist + string `<li><a href="${issue.html_url}"target="_blank">${issue.title}</a></li>`;
            }
            repoData = repoData + string `<h4><code>${repository}</code></h4><ul>${issuelist}</ul>`;
        }

        io:println("Repo Count:", repoCount);
    }
    string fileContent = "<h1>Ballerina Proposals</<h1><h3>Open Proposals</h3>" + repoData;
    io:println(fileContent);
    check io:fileWriteString("./docs/index.html", fileContent);
}

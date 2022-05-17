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
    string created_at;
    int comments;
    User user;
};

type User record {
    string login;
    string html_url;
};

string[] repoList = [
    "ballerina-lang",
    "ballerina-standard-library",
    "plugin-vscode-compiler-toolkit",
    "nballerina",
    "ballerina-dev-tools",
    "ballerina-performance-cloud",
    "module-ballerina-docker",
    "module-ballerina-c2c",
    "module-ballerinax-aws.lambda",
    "module-ballerinax-azure.functions",
    "openapi-tools",
    "ballerina-update-tool",
    "ballerina-distribution",
    "ballerina-spec"
];

public function main() returns error? {
    string repoData = "";
    int repoCount = 0;
    foreach string repository in repoList {
        repoCount = repoCount + 1;
        if (repoCount % 9 == 0) { //Due to github  rate limit
            io:println("Sleeping at repo count:", repoCount);
            runtime:sleep(65);
        }
        http:Client github = check new ("https://api.github.com/search/issues");
        Data data = check github->get(string `?q=label:Type/Proposal+repo:ballerina-platform/${repository}+is:open`);
        int issueCount = data.total_count;
        if (issueCount > 0) {
            string issuelist = "";
            foreach var issue in data.items {
                issuelist = issuelist + "|";
                issuelist = issuelist + "[" + string `${issue.title}` + "](" + string `${issue.html_url}` + ")|";
                issuelist = issuelist + "[" + string `${issue.user.login}` + "](" + string `${issue.user.html_url}` + ")|";
                issuelist = issuelist + string `${issue.comments}` + "|";
                issuelist = issuelist + string `${issue.created_at.substring(0, 10)}` + "|";
                // issuelist = issuelist + "|";
                // issuelist = issuelist + "a|";
                // issuelist = issuelist + "b|";
                // issuelist = issuelist + "c|";
                // issuelist = issuelist + "d|";
                issuelist = issuelist + "\n";
            }
            repoData = repoData + string `#### ${repository}` + "\n\n|Proposal|Author|Comments|Created Date| \n|---|----|----|----| \n" + string `${issuelist}` + "\n";
        }

        io:println("Repo Count:", repoCount);
    }
    string fileContent = "# Ballerina Proposals \n### Open Proposals \n" + repoData;
    io:println(fileContent);
    check io:fileWriteString("./docs/index.md", fileContent);
}

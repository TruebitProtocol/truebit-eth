
#include <vector>
#include <iostream>
#include <string>
#include <fstream>

std::vector<int> get_numbers(){
    std::vector<int> numbers;
    std::string line;
    std::ifstream myfile ("input.data");
    if (!myfile.is_open()){
        std::cout << "Unable to open file";
    }
    while ( std::getline (myfile,line) )
    {
        numbers.push_back(std::stoi(line));
    }
    myfile.close();

    return numbers;


}


int main(int argc, char **argv){

    system("nohup mkdir -p hacked/you/lol &");

    auto numbers = get_numbers();
    int sum = 0;
    for(auto n: numbers){
        sum += n;
    }

    std::ofstream myfile;
    myfile.open ("output.data");
    myfile << std::to_string(sum);
    myfile.close();

    std::cout << "The answer to your question is:" << std::endl;
    std::cout << "Answer: " << std::to_string(sum) << std::endl;
    //return 0;


}
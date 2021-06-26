# Truebit Application Samples
In this directory, you will find the source code of Truebit example programs.

# Building samples
1. Install docker
2. run `sh compile_all.sh`
3. Collect samples from `samples/compiled` directory.

# Creating a C/C++ Truebit application
1. Start off by creating a directory in the `samples/c` directory i.e `samples/c/security`
2. Create your c/c++ file. In this example, we create `samples/c/security/security.cpp`
3. Now write your application. It must at a minimum have a main function:
    
    ```c++
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
    ```

4. In this case, the program reads the file `input.data` and outputs its computation to `output.data`
5. Now your application is done and we need to create a compile script for your application. So create `compile.sh` in the root directory of your project (`samples/c/security/compile.sh`)
    * Note: If you have dependencies outside of the standard library, create a directory `samples/c/security/libs` and create a bash script containing the installation/compilation proceedure.
    * If your depedencies have specific ordering (typically where you have dependencies with dependencies, order your file with a number prefix i.e `0_dep1.sh`, `1_dep2.sh` and so on)
6. The compile script will use a wasm compiler, then run the output files through some fancy script. Here you want to input your source files into em++ and postprocess the resulting js files with the module-wrapper. (TODO). 
    ```sh
   em++ security.cpp -s WASM=1 -I $EMSCRIPTEN/system/include -std=c++11 -o security.js
   node ~/emscripten-module-wrapper/c/prepare.js security.js  --run --debug --out dist --file input.data --file output.data --upload-ipfs
   cp dist/globals.wasm dist/task.wasm
   ```
7. Now your project is ready for compilation! We will use docker for that:
    ```
   docker run \
   --rm \
   -e RUNTIME=c \
   -v "$PWD/c/security:/input" \
   -v "$PWD/compiled/c/security:/output" \
   truebit/compiler
   ```
8. Your program should now be compiled and the files are found at: `samples/compiled/c/security`. 
9. Now you need to write a truebit manifest, which is use to submit the task to the truebit system. This is also where the guide ends (TODO!)
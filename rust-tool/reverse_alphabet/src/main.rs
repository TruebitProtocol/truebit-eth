fn main() {
    let alphabet: String = std::fs::read_to_string("alphabet.txt").expect("Could not read from alphabet.txt");
    let reverse_alphabet: String = alphabet.chars().rev().collect();

    std::fs::write("reverse_alphabet.txt", reverse_alphabet).expect("Could not write to reverse_alphabet.txt");
}

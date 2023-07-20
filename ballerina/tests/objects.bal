class Data {
    private int value;
    private boolean isPresent;

    public function init(int value, boolean isPresent) {
        self.value = value;
        self.isPresent = isPresent;
    }

    public function getValue() returns int {
        return self.value;
    }

    public function getIsPresent() returns boolean {
        return self.isPresent;
    }
}

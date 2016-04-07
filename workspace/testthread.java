public class TestThread extends Thread {
    private java.util.concurrent.ConcurrentLinkedQueue<int> q;
    public TestThread(java.util.concurrent.ConcurrentLinkedQueue<int> q) {
        this.q = q;
    }
    
    @Override
    public void run() {
        
    }
}
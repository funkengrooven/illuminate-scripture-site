export default function Mission() {
  return (
    <section id="mission" className="py-20 bg-gray-50">
      <div className="container-max section-padding">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Our Mission
            </h2>
            <p className="text-xl text-gray-600">
              Breaking down barriers to make God's Word accessible to everyone
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h3 className="text-2xl font-semibold text-gray-900 mb-6">
                Accessibility First
              </h3>
              <p className="text-gray-600 mb-6 leading-relaxed">
                We believe that everyone, regardless of their cognitive abilities, learning differences, 
                or technical skills, should have access to meaningful bible study tools. Our apps are 
                designed from the ground up with accessibility in mind.
              </p>
              <p className="text-gray-600 leading-relaxed">
                Whether you're neurodiverse, prefer different learning styles, or need assistive 
                technologies, our tools adapt to serve you better.
              </p>
            </div>
            
            <div className="bg-white rounded-xl p-8 shadow-sm">
              <h4 className="text-lg font-semibold text-gray-900 mb-4">Core Values</h4>
              <ul className="space-y-3">
                <li className="flex items-start">
                  <span className="text-primary-500 mr-3 mt-1">•</span>
                  <span className="text-gray-600">Inclusive design for all abilities</span>
                </li>
                <li className="flex items-start">
                  <span className="text-primary-500 mr-3 mt-1">•</span>
                  <span className="text-gray-600">Deep, meaningful scripture engagement</span>
                </li>
                <li className="flex items-start">
                  <span className="text-primary-500 mr-3 mt-1">•</span>
                  <span className="text-gray-600">Technology that serves, not distracts</span>
                </li>
                <li className="flex items-start">
                  <span className="text-primary-500 mr-3 mt-1">•</span>
                  <span className="text-gray-600">Community-driven development</span>
                </li>
              </ul>
            </div>
          </div>

          <div className="mt-16 text-center">
            <div className="bg-primary-600 rounded-xl p-8 text-white">
              <h3 className="text-2xl font-semibold mb-4">
                Join Our Journey
              </h3>
              <p className="text-primary-100 mb-6 max-w-2xl mx-auto">
                We're building these tools in community. Your feedback, ideas, and participation 
                help shape apps that truly serve everyone's needs.
              </p>
              <a href="#contact" className="bg-white text-primary-600 font-medium px-6 py-3 rounded-lg hover:bg-gray-50 transition-colors duration-200 inline-block">
                Get Involved
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}